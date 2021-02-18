const paths = {
	srkbz(subpath) {
		const [workdir] = os.getcwd();
		return workdir + '/' + subpath;
	},
}

const log = {
	title(text) {
		console.log(`:: ${text}`);
	},
	info(text) {
		console.log(`:::: ${text}`);
	}
}

function cmd(args) {
	const [output_read, output_write] = os.pipe()
	const [error_read, error_write] = os.pipe()
	os.exec(args, { stdout: output_write, stderr: error_write })
	os.close(output_write)
	os.close(error_write)
	return [
		std.fdopen(output_read, 'r').readAsString(),
		std.fdopen(error_read, 'r').readAsString()
	]
}
