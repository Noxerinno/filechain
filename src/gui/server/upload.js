const execSync = require('child_process').execSync;
console.log("Start child process");

function upload(req) {
	for (const file of req.files) {
		try {
			const result = execSync("cd ../../ipfs/interact;bash upload.sh ../../gui/server/tmp/" + file.filename);
			uploaded = uploaded + 1;
			console.log("Done with file :" + result.toString());
			// if(uploaded == req.files.length) return res.json({content: "Files uploaded"});
		} catch (e) {
			console.log(`error: ${e.message}`);
		}
		process.send({cnt: uploaded});
	}
}

process.on('message', (req) => {
	console.log("Start upload !");
	upload(req)
})