blue_bold "Cleaning build caches"
# shellcheck disable=SC2154
declare code_directory="${args[code-directory]}"

readarray -t nodeModulesList < <(find "$code_directory" -type d -name node_modules)
readarray -t buildList < <(find "$code_directory" -type d -name build)
readarray -t outList < <(find "$code_directory" -type d -name out)
readarray -t cdkOutList < <(find "$code_directory" -type d -name cdk.out)
readarray -t pycacheList < <(find "$code_directory" -type d -name __pycache__)
readarray -t cargoList < <(find "$code_directory" -type f -name Cargo.toml -exec dirname {} \;)

blue_bold "Cleaning 'node_modules' directories..."
spinny-start
for nodeModulesDirectory in "${nodeModulesList[@]}"; do
	blue_bold "Cleaning 'node_modules' directory: $nodeModulesDirectory"
	sudo rm -rf "$nodeModulesDirectory"
done
spinny-stop

blue_bold "Cleaning 'build' directories..."
spinny-start
for buildDirectory in "${buildList[@]}"; do
	blue_bold "Cleaning 'build' directory: $buildDirectory"
	sudo rm -rf "$buildDirectory"
done
spinny-stop

blue_bold "Cleaning 'out' directories..."
spinny-start
for outDirectory in "${outList[@]}"; do
	blue_bold "Cleaning 'out' directory: $outDirectory"
	sudo rm -rf "$outDirectory"
done
spinny-stop

blue_bold "Cleaning 'cdk.out' directories..."
spinny-start
for cdkOutDirectory in "${cdkOutList[@]}"; do
	blue_bold "Cleaning 'cdk.out' directory: $cdkOutDirectory"
	sudo rm -rf "$cdkOutDirectory"
done
spinny-stop

blue_bold "Cleaning 'pycache' directories..."
spinny-start
for pycacheDirectory in "${pycacheList[@]}"; do
	blue_bold "Cleaning 'pycache' directory: $pycacheDirectory"
	sudo rm -rf "$pycacheDirectory"
done
spinny-stop

blue_bold "Cleaning 'Rust' projects..."
spinny-start
for cargoDirectory in "${cargoList[@]}"; do
	blue_bold "Cleaning rust project: $cargoDirectory"
	# shellcheck disable=SC2164
	pushd "$cargoDirectory" > /dev/null 2>&1
	cargo clean
	# shellcheck disable=SC2164
	popd > /dev/null 2>&1
done

blue_bold "Cleaning the ~/.m2/repository cache..."
rm -rf "$HOME"/.m2/repository

green_bold "Finished cleaning build caches"
