const express = require("express");
const createClient = require('ipfs-http-client');
const cors = require('cors')
const multer = require('multer')
const execSync = require('child_process').execSync;
const multiaddr = require('multiaddr')

const client = createClient();
const app = express();

// Middleware
app.use(express.json({limit: '50mb'}));
app.use(cors())
app.use(express.urlencoded({limit: '50mb', extended: true}));

const upload = multer({
	dest: "./tmp/"
})

// var storage = multer.diskStorage({
// 	destination: function (req, file, cb) {
// 		cb(null, 'tmp/')
// 	},
// 	filename: function (req, file, cb) {
// 		cb(null, Date.now() + file.originalname)
// 	}
// })
      
// var upload = multer({ storage: storage })

// get ipfs id
app.get("/api/get/ipfs-id", (req, res) => {
	client.id().then(val => {
		res.send({"id": val.id});
	}).catch(err => {
		res.send(err);
		console.error(err)
	})
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

// upload file to server
app.post("/api/upload", upload.array('files', 10), function(req, res) {
	var uploaded = 0;
	console.log(req.files);
	for (const file of req.files) {
		console.log("Starting next");
		try {
			const result = execSync("cd ../../ipfs/interact;bash upload.sh ../../gui/server/tmp/" + file.filename);
			console.log("After exec line");
			uploaded = uploaded + 1;
			console.log("Done with file :" + result.toString());
			if(uploaded == req.files.length) return res.json({content: "Files uploaded"});
		} catch (e) {
			console.log(`error: ${e.message}`);
		}			
	}	
	// res.send({ status: 200});
})

app.listen(process.env.PORT || 3000, err => {
	if (err) console.error(err);
	console.log("Server has started on port %s", 3000 || process.env.PORT);
})