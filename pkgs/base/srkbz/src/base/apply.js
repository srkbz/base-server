import * as u from './utils.js'

function main() {
	applyUFW();
}

function applyUFW() {
	title('Configuring UFW')
	const ufwRules = getUFWRules();

	info('ufw --force reset')
	u.cmd(['ufw', '--force', 'reset']);
	u.cmd(['sh', '-c', 'rm /etc/ufw/*rules.*'])

	ufwRules.forEach(r => {
		info(`ufw ${r}`)
		u.cmd(['sh', '-c', `ufw ${r}`]);
	})

	info('ufw --force enable')
	u.cmd(['ufw', '--force', 'enable']);
}

function getUFWRules() {
	return Array.prototype.concat.apply([], getUFWConfigFiles()
		.map(f => std.loadFile(f)
			.split('\n')
			.filter(line => !!line)))
}

function getUFWConfigFiles() {
	const base = u.paths.srkbz('features/ufw');
	const [files] = os.readdir(base)
	return files
		.filter(f => f !== '.' && f !== '..')
		.map(f => base + '/' + f);
}

function title(text) {
	console.log(`:: ${text}`);
}

function info(text) {
	console.log(`:::: ${text}`);
}

main();
