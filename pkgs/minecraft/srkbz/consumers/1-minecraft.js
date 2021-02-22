function main() {
	log.title("Ensuring Minecraft workspace")
	run('mkdir', '-p', paths.srkbz('workspace/minecraft'))
	run('chown', '-R', 'minecraft:minecraft', paths.srkbz('workspace/minecraft'))
}

const run = (...args) => {
	const exitCode = os.exec(args);
	if (exitCode > 0) throw new Error(`Command ${JSON.stringify(args)} failed with exit code ${exitCode}`);
}

main();
