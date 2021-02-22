function main() {
	log.title("Ensuring identities")
	const identities = getIdentities();

	identities.groups.forEach(group => {
		log.info(`group: ${group}`);
		os.exec(['bash', '-c', `getent group "${group}" &>/dev/null || groupadd --system "${group}"`]);
	});

	identities.users.forEach(user => {
		log.info(`user: ${user.username}`);
		os.exec(['bash', '-c', `id -u "${user.username}" &>/dev/null || useradd ${[
			'--system',
			'--gid', `"${user.group}"`,
			'--home-dir', `"${user.home}"`, '--create-home',
			'--shell', '/usr/bin/bash',
			`"${user.username}"`
		].join(' ')}`]);
	});
}

function getIdentities() {
	const identityConfigs = getIdentityFiles()
		.map(f => JSON.parse(std.loadFile(f)))
	return {
		groups: Array.prototype.concat.apply([], identityConfigs.map(c => c.groups)),
		users: Array.prototype.concat.apply([], identityConfigs.map(c => c.users))
	}
}

function getIdentityFiles() {
	const base = paths.srkbz('features/identities');
	const [files] = os.readdir(base)
	return (files || [])
		.filter(f => f !== '.' && f !== '..')
		.map(f => base + '/' + f);
}

main();
