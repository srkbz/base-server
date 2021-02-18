function main() {
	log.title('Configuring UFW')
	const ufwRules = getUFWRules();

	log.info('ufw --force reset')
	cmd(['ufw', '--force', 'reset']);
	cmd(['sh', '-c', 'rm /etc/ufw/*rules.*'])

	ufwRules.forEach(r => {
		log.info(`ufw ${r}`)
		cmd(['sh', '-c', `ufw ${r}`]);
	})

	log.info('ufw --force enable')
	cmd(['ufw', '--force', 'enable']);
}

function getUFWRules() {
	return Array.prototype.concat.apply([], getUFWConfigFiles()
		.map(f => std.loadFile(f)
			.split('\n')
			.filter(line => !!line)))
}

function getUFWConfigFiles() {
	const base = paths.srkbz('features/ufw');
	const [files] = os.readdir(base)
	return files
		.filter(f => f !== '.' && f !== '..')
		.map(f => base + '/' + f);
}

main();
