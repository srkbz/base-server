function main() {
	const consumers = getConsumers();
	consumers.forEach(c => {
		os.exec(
			['qjs', '--std', '--include', paths.srkbz('src/base/common.js'), c],
			{ cwd: paths.srkbz('') });
	});
}

function getConsumers() {
	const base = paths.srkbz('consumers');
	const [files] = os.readdir(base)
	return files
		.filter(f => f !== '.' && f !== '..')
		.map(f => base + '/' + f);
}

main();
