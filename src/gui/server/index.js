const express = require("express");
const createClient = require('ipfs-http-client');
const cors = require('cors')
const multer = require('multer')
const execSync = require('child_process').execSync;
const fs = require('fs');
// const multiaddr = require('multiaddr')

const client = createClient();
const app = express();

// Middleware
app.use(express.json({limit: '50mb'}));
app.use(cors())
app.use(express.urlencoded({limit: '50mb', extended: true}));

const upload = multer({
	dest: "./tmp/"
})

// get ipfs id
app.get("/api/get/ipfs-id", (req, res) => {
	client.id().then(val => {
		res.send({"id": val.id});
	}).catch(err => {
		res.send(err);
		console.error(err)
	})
})

// get path
app.get("/api/get/path", (req, res) => {
	let rawdata = fs.readFileSync('data/db.json');
	let db = JSON.parse(rawdata);
	res.send({path: db.path})
})

// get all files metadata
app.get("/api/get/files-metadata", (req, res) => {
	try {
		const result = execSync("bash ../../ipfs/interact/getAllFiles.sh");
		console.log("Done with file :" + result.toString());
		let files = JSON.parse(result.toString());
		res.send({files: files})
	} catch (e) {
		console.log(`error: ${e.message}`);
	}
})

// get ipfs data
app.get("/api/get/ipfs-data", async (req, res) => {
	var response = {};
	await client.id().then(val => {
		response.id = val.id;
		response.address = val.addresses[1].nodeAddress().address;
		response.agentVersion = val.agentVersion;
	}).catch(err => {
		res.send(err);
		console.error(err)
	})
	await client.swarm.peers().then(peersInfos => {
		var peers = [];
		var obj = {}			
		for(const idx in peersInfos) {
			obj = {}
			obj.peer = peersInfos[idx].peer;
			obj.address = peersInfos[idx].addr.nodeAddress().address;
			peers.push(Object.assign({}, obj));
		}
		response.peers = peers;
	});
	res.send(response);

})

function uploadFunction(req) {
	return new Promise(resolve => {
		var uploaded = 0;
		for (const file of req.files) {
			// io.sockets.emit("PROGRESS", {cnt: 1});
			console.log(file);
			try {
				const result = execSync("cd ../../ipfs/interact;bash upload.sh ../../gui/server/tmp/" + file.filename + " " + file.originalname,);
				uploaded = uploaded + 1;
				fs.unlinkSync('./tmp/' + file.filename);
				console.log("Done with file :" + result.toString());
			} catch (e) {
				console.log(`error: ${e.message}`);
			}
		}
		resolve('done');
	});
}
// upload file to server
app.post("/api/upload", upload.array('files', 10), async function(req, res) {
	await uploadFunction(req).then((data) => {
		setTimeout(() => {
			return res.json({content: data});
		}, 3000)
	});
})

// upload file to server
app.post("/api/download", async function(req, res) {
	try {
		console.log(req.body);
		let rawdata = fs.readFileSync('data/db.json');
		let db = JSON.parse(rawdata);
		const result = execSync("cd ../../ipfs/interact;bash download.sh '" + JSON.stringify(req.body) + "' '" + req.body.filename + "' " + db.path);
		console.log(result)
		res.json({response: true});
	} catch (e) {
		console.log(`error: ${e.message}`);
	}
})

//submit path
app.post("/api/submitPath", (req, res) => {
	console.log(req.body.path);
	const result = execSync(`[ -d \"${req.body.path}\" ] && echo \"True\" || echo \"False\"`, { encoding: 'utf8'});
	console.log(result);
	if (result.toString() == "True\n") {
		let rawdata = fs.readFileSync('data/db.json');
		let db = JSON.parse(rawdata);
		db.path = req.body.path;
		let data = JSON.stringify(db);
		fs.writeFileSync('data/db.json', data);
		return res.json({valid: true});
	}
	return res.json({valid: false});
})

// var sockets = []
app.listen(process.env.PORT || 3000, err => {
	if (err) console.error(err);
	console.log("Server has started on port %s", 3000 || process.env.PORT);
})
// const io = require('socket.io')(server, {
// 	cors: {
// 		origin: "http://localhost:8081",
// 		methods: ["GET", "POST"]
// 	}
// });

// io.on("connection", function(socket) {
// 	sockets.push(socket);
// 	console.log(`Client connected: ${socket.id}`);
// 	socket.on('DISCONNECT', function() {
// 		console.log(socket.id + " disconnected");
// 		var i = sockets.indexOf(socket);
// 		sockets.splice(i,1);
// 	});
// })