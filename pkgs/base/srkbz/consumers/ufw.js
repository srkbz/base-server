function main() {
	log.title('Configuring UFW');

	log.info('ufw --force reset');
	cmd(['ufw', '--force', 'reset']);
	cmd(['sh', '-c', 'rm /etc/ufw/*rules.*']);

	getUFWRules().forEach(r => {
		const command = `ufw ${r}`;
		log.info(command);
		cmd(['sh', '-c', command]);
	})

	log.info('ufw --force enable');
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
