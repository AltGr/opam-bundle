(**************************************************************************)
(*                                                                        *)
(*    Copyright 2017 OCamlPro                                             *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

open OpamTypes
open OpamStateTypes
open OpamProcess.Job.Op


let bootstrap_packages ocamlv = [
  OpamPackage.Name.of_string "ocaml-base-compiler", Some (`Eq, ocamlv);
]

let system_ocaml_package_name = OpamPackage.Name.of_string "ocaml-system"

let wrapper_ocaml_package_name = OpamPackage.Name.of_string "ocaml"

let ocaml_config_package_name = OpamPackage.Name.of_string "ocaml-config"

(* This package will be created solely for the bundle, and replaces
   ocaml-system *)
let bootstrap_ocaml_package_name = OpamPackage.Name.of_string "ocaml-bootstrap"
let bootstrap_ocaml_package ocamlv =
  OpamPackage.create bootstrap_ocaml_package_name ocamlv

let additional_user_packages ocamlv = [
  OpamSolution.eq_atom_of_package (bootstrap_ocaml_package ocamlv);
]

let hardcoded_env ocamlv opamv = [
  OpamVariable.of_string "sys-ocaml-version",
  (lazy (Some (S (OpamPackage.Version.to_string ocamlv))),
   "Pre-selected OCaml version");
  OpamVariable.of_string "opam-version",
  (lazy (Some (S (OpamPackage.Version.to_string opamv))),
   "Pre-selected opam version");
]

(* Used to optimise solving times: we know we'll never need those (since we
   require a definite version, and hardcode the use of ocaml-base-compiler for
   bootstrap (and ocaml-bootstrap for reuse) *)
let exclude_packages ocamlv = [
  OpamPackage.Name.of_string "ocaml", Some (`Neq, ocamlv);
  OpamPackage.Name.of_string "ocaml-variants", None;
  OpamPackage.Name.of_string "ocaml-system", None;
]

let opam_archive_url opamv =
  let tag =
    OpamStd.String.map (function '~' -> '-' | c -> c)
      (OpamPackage.Version.to_string opamv)
  in
  Printf.sprintf
    "https://github.com/ocaml/opam/releases/download/%s/opam-full-%s.tar.gz"
    tag tag
  |> OpamUrl.of_string

let output_extension = "tar.gz"

let stdlib_output = output

let create_bundle ocamlv opamv repo debug output env test doc yes self_extract
    packages_targets =
  OpamClientConfig.opam_init
    ~debug_level:(if debug then 1 else 0)
    ~yes:(if yes then Some true else None)
    ();
  let packages = List.map fst packages_targets in
  let ocamlv = match ocamlv with
    | Some v -> v
    | None ->
      let v =
        try
          OpamPackage.Version.of_string @@
          List.hd (OpamSystem.read_command_output ["ocamlc"; "-vnum"])
        with e -> OpamStd.Exn.fatal e; OpamPackage.Version.of_string "4.04.1"
      in
      OpamConsole.formatted_msg "No OCaml version selected, will use %s.\n"
        (OpamConsole.colorise `bold @@ OpamPackage.Version.to_string v);
      v
  in
  let opamv = match opamv with
    | Some v -> v
    | None -> OpamPackage.Version.of_string "2.1.0~rc2"
  in
  let output = match output, packages with
    | Some f, _ ->
      if not (String.contains (OpamFilename.(Base.to_string (basename f))) '.')
      then OpamFilename.add_extension f output_extension
      else f
    | None, (name, _)::_ ->
      OpamFilename.of_string
        (OpamPackage.Name.to_string name ^"-bundle."^output_extension)
    | None, [] -> assert false
  in
  let bundle_name =
    Filename.basename @@
    OpamFilename.remove_suffix
      (OpamFilename.Base.of_string ("."^output_extension))
      output
  in
  let env =
    match env with
    | Some e ->
      let comment = "Manually defined" in
      List.map (fun s ->
          match OpamStd.String.cut_at s '=' with
          | Some (var,value) ->
            OpamVariable.of_string var, (lazy (Some (S value)), comment)
          | None ->
            OpamVariable.of_string s, (lazy (Some (B true)), comment))
        e
      |> OpamVariable.Map.of_list
    | None ->
      let e =
        List.map (fun (v,x) -> v, (x, "Inferred from current system"))
            OpamSysPoll.variables
      in
      OpamConsole.formatted_msg
        "No environment specified, will use the following for package \
         resolution (based on the host system):\n%s"
        (OpamStd.Format.itemize (fun (v, (lazy c, _)) ->
             Printf.sprintf "%s = %S"
               (OpamConsole.colorise `bold @@ OpamVariable.to_string v)
               (OpamStd.Option.to_string
                  OpamVariable.string_of_variable_contents c))
            e);
      OpamVariable.Map.of_list e
  in
  let env =
    OpamVariable.Map.union (fun a _ -> a)
      env
      (OpamVariable.Map.of_list (hardcoded_env ocamlv opamv))
  in
  let packages_filter =
    let module L = OpamListCommand in
    OpamFormula.ands [
      if OpamVariable.Map.is_empty env then Atom L.Any else Atom L.Available;
      OpamFormula.ors [
        Atom (L.Solution (L.default_dependency_toggles,
                          bootstrap_packages ocamlv));
        Atom (L.Solution ({L.default_dependency_toggles with L.test; doc},
                          packages @ additional_user_packages ocamlv));
      ]
    ]
  in
  OpamFilename.with_tmp_dir @@ fun tmp ->
  let opam_root = OpamFilename.Op.(tmp / "root") in
  OpamStateConfig.update ~root_dir:opam_root ();
  (* let repos_dir = OpamFilename.Op.(tmp / "repos") in *)
  (* *** *)
  OpamConsole.header_msg "Initialising repositories";
  let gen_repo_name repos_map base =
    let rec uniq i =
      let name =
        OpamRepositoryName.of_string
          (Printf.sprintf "%s%s" base
             (if i = 0 then "" else string_of_int i))
      in
      if OpamRepositoryName.Map.mem name repos_map then uniq (i+1)
      else name
    in
    uniq 0
  in
  let repos_list_rev, repos_map =
    List.fold_left (fun (repos_list_rev, repos_map) url ->
        let name =
          match OpamStd.String.split url.OpamUrl.path '/' with
          | s::_ -> gen_repo_name repos_map s
          | [] -> gen_repo_name repos_map "repository"
        in
        let repo = {
          repo_name = name;
          repo_url = url;
          repo_trust = None;
        } in
        repo.repo_name :: repos_list_rev,
        OpamRepositoryName.Map.add repo.repo_name repo repos_map)
      ([], OpamRepositoryName.Map.empty)
      repo
  in
  let repos_list = List.rev repos_list_rev in
  let dl_cache =
    let std_opamroot = OpamStateConfig.opamroot () in
    [OpamUrl.parse ~backend:`rsync
       (OpamFilename.Dir.to_string
          (OpamRepositoryPath.download_cache std_opamroot))]
  in
  let gt = {
    global_lock = OpamSystem.lock_none;
    root = opam_root;
    config =
      OpamFile.Config.empty
      |> OpamFile.Config.with_repositories repos_list
      |> OpamFile.Config.with_dl_cache dl_cache;
    global_variables = env;
  } in
  let rt = {
    repos_global = (gt :> unlocked global_state);
    repos_lock = OpamSystem.lock_none;
    repositories = repos_map;
    repos_definitions =
      OpamRepositoryName.Map.map (fun r ->
          OpamFile.Repo.safe_read
            OpamRepositoryPath.(repo (root gt.root r.repo_name)) |>
          OpamFile.Repo.with_root_url r.repo_url)
        repos_map;
    repo_opams = OpamRepositoryName.Map.empty;
    repos_tmp = Hashtbl.create 1;
  } in
  let failed_repos, rt =
    OpamRepositoryCommand.update_with_auto_upgrade rt
      (OpamRepositoryName.Map.keys repos_map)
  in
  if failed_repos <> [] then
    OpamConsole.error_and_exit `Sync_error
      "Could not fetch some repositories: %s"
      (OpamStd.List.to_string OpamRepositoryName.to_string failed_repos);
  (* *** Custom packages *)
  let custom_opams =
    let index = OpamRepositoryState.build_index rt repos_list in
    (* Renaming ocaml-system to ocaml-bootstrap avoids confusion from other
       packages *)
    let find_def nv =
      match OpamPackage.Map.find_opt nv index with
      | None ->
        OpamConsole.error_and_exit `Not_found
          "Package %s not found in the repositories"
          (OpamPackage.to_string nv)
      | Some opam -> opam
    in
    let bootstrap_ocaml_opam =
      find_def (OpamPackage.create system_ocaml_package_name ocamlv) |>
      OpamFile.OPAM.with_name bootstrap_ocaml_package_name |>
      OpamFile.OPAM.with_synopsis
        "OCaml compiler generated during the opam-bundle bootstrap phase"
    in
    let fix_compiler_depends opam =
      OpamFile.OPAM.with_depends
        (OpamFormula.map (fun (name, c as at) ->
             if name = system_ocaml_package_name then
               Atom (bootstrap_ocaml_package_name, c)
             else Atom at)
            (OpamFile.OPAM.depends opam))
        opam
    in
    let ocaml_config_packages =
      OpamPackage.Map.filter (function
        | package when OpamPackage.Name.equal ocaml_config_package_name
        @@ OpamPackage.name package ->
          fun _ -> true
        | _  -> fun _ -> false) index |>
      OpamPackage.Map.map fix_compiler_depends
    in
    let wrapper_package =
      OpamPackage.create wrapper_ocaml_package_name ocamlv
    in
    let wrapper_ocaml_opam =
      find_def wrapper_package |> fix_compiler_depends
    in
    OpamPackage.Map.union (fun a _ -> a)
    ocaml_config_packages
    @@ OpamPackage.Map.of_list [
      bootstrap_ocaml_package ocamlv, bootstrap_ocaml_opam;
      wrapper_package, wrapper_ocaml_opam;
    ]
  in
  let external_opams, virtual_pins =
    if List.for_all (fun (_,target) -> target = None) packages_targets then
      OpamPackage.Map.empty, OpamPackage.Map.empty
    else
    let srcs = OpamFilename.Op.(tmp / "sources") in
    OpamConsole.header_msg "Getting external packages";
    let pkgs_urls =
      OpamStd.List.filter_map (function
          | _, None -> None
          | (name, None), Some target -> Some ((name, None), target)
          | (name, Some (`Eq, v)), Some target ->
            Some ((name, Some v), target)
          | _ -> invalid_arg "Only equality constraints are supported")
        packages_targets
    in
    let pkgs_src =
      OpamParallel.map ~jobs:OpamStateConfig.(!r.dl_jobs)
        ~command:(fun ((name, v), url) ->
            let srcdir =
              OpamFilename.Op.(srcs / OpamPackage.Name.to_string name)
            in
            OpamRepository.pull_tree (OpamPackage.Name.to_string name)
              srcdir [] [url] @@| function
            | Not_available (s, _) ->
              OpamConsole.error_and_exit `Sync_error
                "Could not obtain %s from %s%s"
                (OpamPackage.Name.to_string name)
                (OpamUrl.to_string url)
                (OpamStd.Option.to_string (fun s -> ": "^s) s)
            | Up_to_date _ | Result _ -> (name, v), srcdir)
        pkgs_urls
    in
    let pkgs_opams_archives =
      pkgs_src |> List.map @@ fun ((name, v), src) ->
      let allpkgs () =
        OpamRepositoryName.Map.fold
          (fun _ m s -> OpamPackage.Set.union (OpamPackage.keys m) s)
          rt.repo_opams OpamPackage.Set.empty
      in
      let nv, opam =
        match OpamPinned.find_opam_file_in_source name src with
        | Some f ->
          OpamConsole.note
            "Will use package definition found in source for %s"
            (OpamPackage.Name.to_string name);
          let o = OpamFile.OPAM.read f in
          let o = OpamFormatUpgrade.opam_file ~filename:f o in
          let v =
            match v, OpamFile.OPAM.version_opt o with
            | Some v_user, Some v_pkg when v_user <> v_pkg ->
              OpamConsole.warning
                "The package declares itself as version %s, but will use %s, \
                 as specified"
                (OpamPackage.Version.to_string v_pkg)
                (OpamPackage.Version.to_string v_user);
              v_user
            | Some v, _ | _, Some v -> v
            | None, None ->
              let v =
                try OpamPackage.version
                      (OpamPackage.max_version (allpkgs ()) name)
                with Not_found -> OpamPackage.Version.of_string "~dev"
              in
              OpamConsole.warning
                "No version information found for %s. Will use %s"
                (OpamPackage.Name.to_string name)
                (OpamPackage.Version.to_string v);
              v
          in
          OpamPackage.create name v, OpamFile.OPAM.with_version v o
        | None ->
          match v with
          | Some v ->
            (let nv = OpamPackage.create name v in
             match OpamRepositoryState.find_package_opt rt repos_list nv with
             | Some (repo, o) ->
               OpamConsole.note
                 "Sources for %s don't contain a package definition, will use \
                  the one found in the repository at %s"
                 (OpamPackage.to_string nv)
                 (OpamUrl.to_string
                   (OpamRepositoryName.Map.find repo rt.repositories).repo_url);
               nv, o
             | None ->
               OpamConsole.error_and_exit `Not_found
                 "Specified sources for %s don't contain a package definition, \
                  and none was found in the repositories"
                 (OpamPackage.to_string nv)
                 (* note: we could improve by allowing to lookup current
                    pins at this point *))
          | None ->
            try
              let nv = OpamPackage.max_version (allpkgs ()) name in
              match OpamRepositoryState.find_package_opt rt repos_list nv with
              | Some (repo, o) ->
                OpamConsole.note
                  "Sources for %s don't contain a package definition, will \
                   assume version %s and use metadata and build instructions \
                   from the repository at %s"
                (OpamPackage.Name.to_string name)
                (OpamConsole.colorise `bold (OpamPackage.version_to_string nv))
                (OpamUrl.to_string
                   (OpamRepositoryName.Map.find repo rt.repositories).repo_url);
                nv, o
              | None -> assert false
            with Not_found ->
              OpamConsole.error_and_exit `Not_found
                "Specified sources for %s don't contain a package definition, \
                 and none was found in the repositories"
                (OpamPackage.Name.to_string name)
      in
      let archive =
        OpamFilename.Op.(srcs // (OpamPackage.to_string nv^".tar.gz"))
      in
      OpamFilename.mkdir (OpamFilename.dirname archive);
      OpamProcess.Job.run @@
      OpamSystem.make_command "tar"
        ~dir:(OpamFilename.Dir.to_string srcs)
        ["czf"; OpamFilename.to_string archive;
         OpamFilename.remove_prefix_dir srcs src]
      @@> (fun r -> Done (OpamSystem.raise_on_process_error r));
      nv, opam, archive
    in
    let opams =
      List.fold_left
        (fun set (nv, opam, _) -> OpamPackage.Map.add nv opam set)
        OpamPackage.Map.empty
        pkgs_opams_archives
    in
    let virtual_pins =
      List.fold_left (fun acc (nv,_,archive) ->
          OpamPackage.Map.add nv archive acc)
        OpamPackage.Map.empty pkgs_opams_archives
    in
    opams, virtual_pins
  in
  let custom_repo = gen_repo_name rt.repositories "custom" in
  let repos_list = custom_repo :: repos_list in
  let rt =
    { rt with
      repo_opams =
        OpamRepositoryName.Map.add custom_repo
          (OpamPackage.Map.union (fun o _ -> o) custom_opams external_opams)
          rt.repo_opams;
    }
  in
  let packages =
    (* Enforce the pinned-to versions in the request *)
    let pins = OpamPackage.keys virtual_pins in
    List.map (fun (name, _ as at) ->
        try (name, (Some (`Eq, (OpamPackage.package_of_name pins name).version)))
        with Not_found -> at)
      packages
  in
  (* *** *)
  OpamConsole.header_msg "Resolving package set";
  let st =
    OpamSwitchState.load_virtual ~repos_list gt rt
  in
  let available =
    OpamPackage.Map.filter (fun package opam ->
        OpamFilter.eval_to_bool ~default:false
          (OpamPackageVar.resolve_switch_raw ~package gt
             OpamSwitch.unset OpamFile.Switch_config.empty)
          (OpamFile.OPAM.available opam))
      st.opams
    |> OpamPackage.keys
  in
  let st = { st with available_packages = lazy available } in
  let unavailable =
    let required_atoms =
      bootstrap_packages ocamlv @
      packages @
      additional_user_packages ocamlv
    in
    List.filter (fun (name, _ as atom) ->
        not @@ OpamPackage.Set.exists
          (OpamFormula.check atom)
          (OpamPackage.packages_of_name available name))
      required_atoms
  in
  if unavailable <> [] then
    OpamConsole.error_and_exit `Not_found
      "The following packages do not exist in the specified repositories, or \
       are not available with the given configuration:\n%s"
      (OpamStd.Format.itemize
         (fun (name, cstr as atom) ->
            Printf.sprintf "%s: %s"
              (OpamFormula.short_string_of_atom atom)
              (OpamSwitchState.unavailable_reason st ~default:"not found"
                 (name, match cstr with None -> OpamFormula.Empty | Some c -> Atom c)))
         unavailable);
  let st = (* this is just an optimisation, to relieve the solver *)
    let filter =
      let excl =
        OpamFormula.ors
          (List.map (fun a -> Atom a) (exclude_packages ocamlv))
      in
      OpamPackage.Set.filter (fun nv ->
          not @@ OpamFormula.eval (fun at -> OpamFormula.check at nv) excl)
    in
    { st with
      packages = filter st.packages;
      available_packages = lazy (filter (Lazy.force st.available_packages));
    }
  in
  let include_packages =
    try OpamListCommand.filter ~base:st.packages st packages_filter
    with Failure msg ->
      OpamConsole.error "Sorry, no consistent installation could be found \
                         including the requested packages.";
      OpamConsole.errmsg "%s" msg;
      OpamStd.Sys.exit_because `No_solution;
  in
  let install_packages =
    OpamFormula.packages_of_atoms include_packages packages
  in
  if OpamPackage.Set.is_empty include_packages then
    OpamConsole.error_and_exit `No_solution
      "No packages match the selection criteria";
  OpamConsole.formatted_msg "The following packages will be included:\n%s"
    (OpamStd.Format.itemize (fun nv ->
         let color =
           if OpamPackage.Set.mem nv install_packages then [`bold; `underline]
           else [`bold]
         in
         OpamConsole.colorise' color (OpamPackage.name_to_string nv) ^"."^
         OpamPackage.version_to_string nv)
        (OpamPackage.Set.elements include_packages));
  let avail_constraint =
    let rec filter_to_list = function
      | FBool true -> []
      | FAnd (f1, f2) -> filter_to_list f1 @ filter_to_list f2
      | f -> [f]
    in
    OpamPackage.Set.fold (fun nv acc ->
        FAnd (acc, OpamFile.OPAM.available (OpamSwitchState.opam st nv)))
      include_packages (FBool true) |>
    OpamFilter.partial_eval (fun v ->
        match OpamVariable.Full.to_string v with
        | "opam-version" -> Some (S (OpamPackage.Version.to_string opamv))
        | "sys-ocaml-version" -> Some (S (OpamPackage.Version.to_string ocamlv))
        | _ -> None) |>
    filter_to_list |>
    List.fold_left (fun acc f ->
        if List.mem f acc then acc else f::acc)
      [] |>
    List.fold_left (fun acc f ->
        if acc = FBool true then f else FAnd (f,acc))
      (FBool true)
  in
  if avail_constraint = FBool true then
    OpamConsole.formatted_msg
      "According to the packages' metadata, the bundle should be installable \
       on %s arch/OS.\n"
      (OpamConsole.colorise `bold "any")
  else
    OpamConsole.formatted_msg
      "The bundle will be installable on systems matching the following: %s\n"
      (OpamConsole.colorise `bold (OpamFilter.to_string avail_constraint));
  OpamConsole.note
    "Opam system sandboxing (introduced in 2.0) will be disabled in the \
     bundle. You need to trust that the build scripts of the included packages \
     don't write outside of their build directory and dest dir.";
  if not @@ OpamConsole.confirm "Continue ?" then
    OpamStd.Sys.exit_because `Aborted;
  (* *** *)
  OpamConsole.header_msg "Getting all archives";
  let bundle_dir = OpamFilename.Op.(tmp / bundle_name) in
  let target_repo = OpamFilename.Op.(bundle_dir / "repo") in
  let cache_dirname = "cache" in
  let target_cache = OpamFilename.Op.(target_repo / cache_dirname) in
  let links_dirname = "archives" in
  let target_links = OpamFilename.Op.(target_repo / links_dirname) in
  OpamFilename.mkdir target_repo;
  OpamFilename.mkdir target_cache;
  OpamFilename.mkdir target_links;
  let repo_file =
    OpamFile.Repo.create
      ~dl_cache:[cache_dirname]
      ()
  in
  OpamFile.Repo.write (OpamRepositoryPath.repo target_repo) repo_file;
  let target_dest f nv =
    f target_repo (Some (OpamPackage.name_to_string nv)) nv
  in
  OpamPackage.Set.iter (fun nv ->
      let opam = OpamSwitchState.opam st nv in
      let orig_dir =
        match OpamFile.OPAM.get_metadata_dir
              ~repos_roots:(OpamRepositoryPath.root gt.root) opam with
        | Some dir -> dir
        | None -> assert false
      in
      let opam_f = OpamFile.make OpamFilename.Op.(orig_dir // "opam") in
      let files_dir = OpamFilename.Op.(orig_dir / "files") in
      let opam = OpamSwitchState.opam st nv in
      OpamFile.OPAM.write_with_preserved_format ~format_from:opam_f
        (target_dest OpamRepositoryPath.opam nv) opam;
      if OpamFilename.exists_dir files_dir then
        OpamFilename.copy_dir
          ~src:files_dir
          ~dst:(target_dest OpamRepositoryPath.files nv))
    include_packages;
  let pull_to_cache nv =
    let link ?extra urlf target =
      let name =
        OpamStd.Option.default
          (OpamUrl.basename (OpamFile.URL.url urlf))
          extra
      in
      let link =
        OpamFilename.Op.(target_links / OpamPackage.to_string nv // name)
      in
      OpamFilename.link ~relative:true ~target ~link
    in
    let dl_job ?extra urlf =
      let source_string =
        Printf.sprintf "%s of %s from %s"
          (match extra with None -> "Source" | Some n -> "Extra source "^n)
          (OpamPackage.to_string nv) (OpamUrl.to_string (OpamFile.URL.url urlf))
      in
      let name = match extra with
        | None -> OpamPackage.to_string nv
        | Some s -> Printf.sprintf "%s/%s" (OpamPackage.name_to_string nv) s
      in
      match OpamFile.URL.checksum urlf with
      | [] ->
        OpamFilename.with_tmp_dir_job @@ fun dldir ->
        let f = OpamFilename.Op.(dldir // OpamPackage.to_string nv) in
        OpamRepository.pull_file name f []
          (OpamFile.URL.url urlf :: OpamFile.URL.mirrors urlf)
        @@| (function
            | Not_available (msg, _) ->
              OpamConsole.error_and_exit `Sync_error
                "%s could not be obtained%s"
                source_string (OpamStd.Option.to_string (fun s -> ": "^s) msg)
            | Result () | Up_to_date () ->
              let hash = OpamHash.compute (OpamFilename.to_string f) in
              let dst = OpamRepository.cache_file target_cache hash in
              OpamFilename.mkdir (OpamFilename.dirname dst);
              OpamFilename.move ~src:f ~dst;
              OpamConsole.warning
                "%s had no recorded checksum: adding %s"
                source_string (OpamHash.to_string hash);
              link ?extra urlf dst;
              OpamFile.URL.with_checksum [hash] urlf)
      | (hash::_) as cksums ->
        let dst = OpamRepository.cache_file target_cache hash in
        OpamRepository.pull_file_to_cache name
          ~cache_dir:target_cache ~cache_urls:dl_cache cksums
          (OpamFile.URL.url urlf :: OpamFile.URL.mirrors urlf)
        @@| (function
            | Not_available (msg, _) ->
              OpamConsole.error_and_exit `Sync_error
                "%s could not be obtained%s"
                source_string (OpamStd.Option.to_string (fun s -> ": "^s) msg)
            | Result (_) | Up_to_date (_) ->
              link ?extra urlf dst;
              urlf)
    in
    let opam = OpamSwitchState.opam st nv in
    let opam0 = opam in
    (match OpamPackage.Map.find_opt nv virtual_pins with
     | Some archive ->
       let hash = OpamHash.compute (OpamFilename.to_string archive) in
       let dst = OpamRepository.cache_file target_cache hash in
       OpamFilename.copy ~src:archive ~dst;
       let urlf =
         OpamFile.URL.create ~checksum:[hash]
           (OpamUrl.parse ~backend:`http
              ("archives/"^OpamFilename.(Base.to_string (basename archive))))
       in
       link urlf dst;
       Done (OpamFile.OPAM.with_url urlf opam)
     | None ->
       match OpamFile.OPAM.url opam with
       | None -> Done opam
       | Some urlf ->
         dl_job urlf @@| fun urlf -> OpamFile.OPAM.with_url urlf opam)
    @@+ fun opam ->
    OpamProcess.Job.seq_map
      (fun (name, urlf) ->
         dl_job ~extra:(OpamFilename.Base.to_string name) urlf @@| fun urlf ->
         name, urlf)
      (OpamFile.OPAM.extra_sources opam)
    @@| fun extra_sources ->
    let opam = OpamFile.OPAM.with_extra_sources extra_sources opam in
    if opam <> opam0 then
      OpamFile.OPAM.write_with_preserved_format
        (target_dest OpamRepositoryPath.opam nv) opam
  in
  let randomised_pkglist =
    (* Some pseudo-randomisation to avoid downloading all files from
       the same host simultaneously *)
    List.sort (fun nv1 nv2 ->
        match compare (Hashtbl.hash nv1) (Hashtbl.hash nv2) with
        | 0 -> compare nv1 nv2
        | n -> n)
      (OpamPackage.Set.elements include_packages)
  in
  OpamParallel.iter ~jobs:OpamStateConfig.(!r.dl_jobs)
    ~command:pull_to_cache
    randomised_pkglist;
  (* *** *)
  OpamConsole.header_msg "Getting bootstrap packages";
  let opam_url = opam_archive_url opamv in
  let opam_archive =
    OpamFilename.Op.(bundle_dir // OpamUrl.basename opam_url)
  in
  OpamProcess.Job.run @@
  OpamRepository.pull_file (OpamUrl.basename opam_url) opam_archive
    [(*todo:checksums*)]
    [opam_url]
  @@| (function
      | Not_available (msg, _) ->
        OpamConsole.error_and_exit `Sync_error
          "Opam archive at %s could not be obtained%s"
          (OpamUrl.to_string opam_url)
          (OpamStd.Option.to_string (fun s -> ": "^s) msg)
      | Result () | Up_to_date () -> ());
  (* *** *)
  OpamConsole.header_msg "Building bundle";
  let include_scripts =
    ["common.sh"; "bootstrap.sh"; "configure.sh"; "compile.sh"]
  in
  let scripts =
    let env v = match OpamVariable.Full.to_string v with
      | "ocamlv" -> Some (S (OpamPackage.Version.to_string ocamlv))
      | "opam_archive" -> Some (S (OpamUrl.basename opam_url))
      | "install_packages" ->
        Some (S (OpamStd.List.concat_map " " OpamPackage.to_string
                   (OpamPackage.Set.elements install_packages)))
      | "doc" -> Some (B doc)
      | "test" -> Some (B test)
      | _ -> None
    in
    List.map (fun name ->
        name, OpamFilter.expand_string env
          (List.assoc name OpamBundleScripts.all_scripts))
      include_scripts
  in
  List.iter (fun name ->
      let script = List.assoc name scripts in
      let file = OpamFilename.Op.(bundle_dir // name) in
      OpamFilename.write file script;
      if name <> "common.sh" then OpamFilename.chmod file 0o755)
    include_scripts;
  OpamProcess.Job.run
    (OpamSystem.make_command ~dir:(OpamFilename.Dir.to_string tmp)
       "tar" ["czf"; OpamFilename.to_string output; bundle_name]
     @@> fun result ->
     OpamSystem.raise_on_process_error result;
     OpamConsole.formatted_msg "Done. Bundle generated as %s\n"
       (OpamFilename.to_string output);
     Done ());
  if self_extract then
    let file =
      OpamFilename.of_string
        (OpamFilename.remove_suffix
           (OpamFilename.Base.of_string ("."^output_extension))
           output
         ^ ".sh")
    in
    let script = OpamBundleScripts.self_extract_sh in
    let blocksize = 512 in
    let rec count_blocks blocks =
      let env v = match OpamVariable.Full.to_string v with
        | "blocksize" -> Some (S (string_of_int blocksize))
        | "blocks" -> Some (S (string_of_int blocks))
        | _ -> None
      in
      let s = OpamFilter.expand_string env script in
      if String.length s > blocksize * blocks then count_blocks (blocks + 1)
      else s, blocks
    in
    let script, blocks = count_blocks 1 in
    let ic = open_in (OpamFilename.to_string output) in
    let oc = open_out (OpamFilename.to_string file) in
    output_string oc script;
    seek_out oc (blocksize * blocks);
    let sz = 4096 in
    let buf = Bytes.create sz in
    let rec copy () =
      let len = input ic buf 0 sz in
      if len <> 0 then (stdlib_output oc buf 0 len; copy ())
    in
    copy ();
    close_in ic;
    close_out oc;
    OpamFilename.chmod file 0o755;
    OpamConsole.formatted_msg "Self-extracting archive generated as %s\n"
      (OpamFilename.to_string file)


(* -- command-line handling -- *)

open Cmdliner

let pkg_version_conv =
  Arg.conv ~docv:"VERSION" (
    (fun s -> try Ok (OpamPackage.Version.of_string s) with Failure s ->
        Error (`Msg s)),
    (fun ppf v -> Format.pp_print_string ppf (OpamPackage.Version.to_string v))
  )

let atom_with_target_conv =
  Arg.conv ~docv:"PACKAGE" (
    (fun s ->
       let atom, target = match OpamStd.String.cut_at s '@' with
         | None -> s, None
         | Some (atom, target) -> atom, Some target
       in
       match Arg.conv_parser OpamArg.atom atom with
       | Error _ as e -> e
       | Ok ((_, cstr) as atom) ->
         match target with
         | None -> Ok (atom, None)
         | Some target ->
           match cstr with
           | None | Some (`Eq, _) ->
             (try Ok (atom, Some (OpamUrl.parse target))
              with Failure s -> Error (`Msg s))
           | _ -> Error (`Msg "Only equality version constraints can be \
                               specified together with a target URL")),
    (fun ppf (atom, target) ->
       Format.fprintf ppf "%a%s"
         (Arg.conv_printer OpamArg.atom) atom
         (OpamStd.Option.to_string (fun u -> "@" ^ OpamUrl.to_string u) target))
  )

let ocamlv_arg =
  Arg.(value & opt (some pkg_version_conv) None & info ["ocaml"] ~doc:
         "Select a version of OCaml to include. It will be used for \
          bootstrapping, and must be able to compile opam.")

let opamv_arg =
  Arg.(value & opt (some pkg_version_conv) None & info ["opam"] ~doc:
         "Select a version of opam to include. That version must be released \
          with an upstream \"full-archive\" available online, and be at least \
          2.0.0~rc2, to support all the required features.")

let repo_arg =
  Arg.(value & opt_all OpamArg.url [OpamInitDefaults.repository_url] &
       info ["repository"] ~docv:"URL" ~doc:
         "URLs of the repositories to use (highest priority first). Note that \
          it is required that the OCaml package at the selected version is \
          included (see $(b,--ocaml)), with the hierarchy and alternatives as \
          on the default repository ('ocaml-base-compiler', 'ocaml-system' and \
          'ocaml-config' packages, with the 'ocaml' wrapper virtual package). \
          This makes it possible to bootstrap opam and compile the requested \
          packages with a single compilation of OCaml.")

let debug_arg =
  Arg.(value & flag & info ["debug"] ~doc:
         "Display debug information about what's going on.")

let output_arg =
  Arg.(value & opt (some OpamArg.filename) None & info ["output";"o"] ~doc:
         "Output the bundle to the given file.")

let env_arg =
  (* TODO: make repeatable to ensure multiple environments will work! *)
  Arg.(value & opt (some (list string)) ~vopt:(Some []) None &
       info ["environment"] ~doc:
         "Use the given opam environment, in the form of a list of \
          comma-separated 'var=value' bindings, when resolving variables. This \
          is used when computing the set of available packages, where opam \
          uses variables $(i,arch), $(i,os), $(i,os-distribution), \
          $(i,os-version) and $(i,os-family): if undefined, the variables are \
          inferred from the current system. If set without argument, an empty \
          environment is used: this can be used to ensure the generated bundle \
          won't have arch or OS constraints.")

let with_test_arg =
  Arg.(value & flag & info ["t";"with-test"] ~doc:
         "Include the packages' test-only dependencies in the bundle, and make \
          the bundle run the tests on installation.")

let with_doc_arg =
  Arg.(value & flag & info ["d";"with-doc"] ~doc:
         "Include the packages' doc-only dependencies in the bundle, and \
          make the bundle generate their documentation.")

let yes_arg =
  Arg.(value & flag & info ["y";"yes"] ~doc:
         "Confirm all prompts without asking.")

let self_extract_arg =
  Arg.(value & flag & info ["self"] ~doc:
         "Generate a self-extracting script besides the .tar.gz bundle")

let packages_arg =
  Arg.(non_empty & pos_all atom_with_target_conv [] &
       info [] ~docv:"PACKAGE" ~doc:
         "List of packages to include in the bundle. Their dependencies will \
          be included as well, but only listed packages will have wrappers \
          installed. Packages can be specified as $(i,NAME[CONSTRAINT][@URL]), \
          where $(i,CONSTRAINT) is an optional version constraint starting \
          with one of $(i,.) or $(i,=), $(i,!=), $(i,>), $(i,>=), $(i,<) or \
          $(i,<=), and $(i,@URL) can be specified to use the package source \
          from the given URL (in which case, the constraint, if any, must be \
          $(i,.) or $(i,=)).")

let man = [
  `S "DESCRIPTION";
  `P "This utility can extract a set of packages from opam repositories, and \
      bundle them together in a comprehensive source archive, with the scripts \
      needed to bootstrap OCaml, opam, and install the packages on a fresh, \
      network-less system.";
  `P "The opam-depext plugin is included to try and get the required system \
      dependencies on the target system (which might, in this case, require \
      network, depending on the system configuration).";
  `P "The generated bundle includes three scripts, each one calling the \
      previous ones if necessary:";
  `I ("$(i,bootstrap.sh)",
      "Compiles OCaml and opam and gets them ready in a local prefix");
  `I ("$(i,configure.sh)",
      "Initialises an opam root within the bundle directory, and gets the \
       required system depdendencies");
  `I ("$(i,compile.sh)",
      "Compiles the required packages using the bootstrapped opam. If a prefix \
       was specified, and for packages listed on the command-line of $(tname), \
       wrappers are installed to the prefix for installed binaries. These \
       execute the programs within the in-bundle opam root, with the proper \
       opam environment.");
  `P "For example, assuming $(i,foo) is a package that installs a $(i,bar) \
      binary, from a bundle generated using $(tname)$(b, foo), a user on a \
      fresh system could run $(b,tar xzf foo-bundle.tar.gz && \
      ./foo-bundle/compile.sh ~/local) to get a usable $(i,bar) binary within \
      $(b,~/local/bin) (if the user does not have write permission to the \
      given prefix, the script will use $(b,sudo)).";
  `P "Note that the extracted bundle itself should not be moved for the \
      wrappers to keep working. Besides the wrappers, nothing is written \
      outside of the directory where the bundle was untarred.";
]

let create_bundle_command =
  Term.(const create_bundle $ ocamlv_arg $ opamv_arg $ repo_arg $ debug_arg $
        output_arg $ env_arg $ with_test_arg $ with_doc_arg $ yes_arg $
        self_extract_arg $
        packages_arg)

let info = Cmd.info "opam-bundle" ~man ~doc:
    "Creates standalone source bundle from opam packages"

let () =
  OpamSystem.init ();
  try
    match Cmd.eval_value ~catch:false (Cmd.v info create_bundle_command) with
    | Error _ -> exit 1
    | _ -> exit 0
  with
  | e ->
    flush stdout;
    flush stderr;
    if (OpamConsole.debug ()) then
      Printf.eprintf "'%s' failed.\n"
        (String.concat " " (Array.to_list Sys.argv));
    let exit_code = ref 1 in
    begin match e with
      | OpamStd.Sys.Exit i ->
        exit_code := i;
        if (OpamConsole.debug ()) && i <> 0 then
          Printf.eprintf "%s" (OpamStd.Exn.pretty_backtrace e)
      | OpamSystem.Internal_error _ ->
        Printf.eprintf "%s\n" (Printexc.to_string e)
      | OpamSystem.Process_error result ->
        Printf.eprintf "%s Command %S failed:\n%s\n"
          (OpamConsole.colorise `red "[ERROR]")
          (try List.assoc "command" result.OpamProcess.r_info with
           | Not_found -> "")
          (Printexc.to_string e);
        Printf.eprintf "%s" (OpamStd.Exn.pretty_backtrace e);
      | Sys.Break
      | OpamParallel.Errors (_, (_, Sys.Break)::_, _) ->
        exit_code := 130
      | Sys_error e when e = "Broken pipe" ->
        (* workaround warning 52, this is a fallback (we already handle the
           signal) and there is no way around at the moment *)
        exit_code := 141
      | Failure msg ->
        Printf.eprintf "Fatal error: %s\n" msg;
        Printf.eprintf "%s" (OpamStd.Exn.pretty_backtrace e);
      | _ ->
        Printf.eprintf "Fatal error:\n%s\n" (Printexc.to_string e);
        Printf.eprintf "%s" (OpamStd.Exn.pretty_backtrace e);
    end;
    exit !exit_code
