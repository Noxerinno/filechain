<template>
<section class="flex w-full h-full transition-colors overflow-x-hidden" ref="drag" :class="isOver ? 'bg-blue-200 shadow-inner' : 'bg-transparent'" v-cloak @drop.prevent="addFile" @dragover.prevent>
	<div class="h-full w-full py-7 mx-44 transition duration-500 transform" v-on:click="select(null)" :class="selected ? '-translate-x-44' : '-translate-x-0'">
		<div class="font-bold text-2xl pb-4 border-b-2 border-gray-300 transition-scale duration-500 mx-5" :class="selected ? 'w-11/12' : 'w-full'"> 
			Storage
		</div>
		<div class="grid grid-cols-5 gap-5 w-full">
			<div class="cursor-pointer m-5 py-5 bg-white transition-color duration-500 rounded-md shadow-lg" v-for="(elm, idx) in files" :key="idx" v-on:click.stop v-on:click="select(elm)" :class="selected == elm ? 'bg-blue-200' : ''"> 
				<div class="flex flex-col items-center">
					<font-awesome-icon :icon="['fas', get_file_type_icon(elm['mime-type'])]" size="6x" class="text-gray-500"/>
					<div class="px-5 pt-3 w-full text-center">
						<div class="overflow-ellipsis truncate">
							{{elm.filename}}
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="absolute h-full bg-white shadow-lg transition duration-500 transform right-0 overflow-hidden" style="width:350px;" :class="selected ? '-translate-x-0' : 'translate-x-96'">
		<div class="text-center font-bold text-2xl pt-14 pb-4 border-b-2 border-gray-300 mx-8 break-words">{{selectedData.filename}}</div>
		<div class="flex flex-col mx-12 mt-5">
			<div class="flex mb-2">
				<div class="font-bold">Created:</div>
				<div class="break-word ml-2">{{selectedData.timestamp}}</div>
			</div>
			<div class="flex mb-2">
				<div class="font-bold">Type:</div>
				<div class="break-all ml-2">{{selectedData.type}}</div>
			</div>	
			<div v-if="downloading" class="mt-5 mx-auto">
				<div v-if="!done" class="flex loader ease-linear rounded-full border-8 border-t-8 border-gray-200 h-10 w-10"></div>
				<font-awesome-icon v-else :icon="['fas', 'check']" size="2x" class="mr-5 text-green-500"/>
			</div>		
			<div v-else class="mt-5 bg-gray-50 shadow-lg mx-auto cursor-pointer group flex items-center px-12 py-2 text-lg leading-6 font-medium rounded-md text-opacity-75 text-black hover:text-opacity-100 hover:bg-blue-500 hover:bg-opacity-30" v-on:click="download()">
				<font-awesome-icon :icon="['fas', 'download']" size="lg" class="mr-5"/>
				Download
			</div>
		</div>
	</div>
	<div class="text-center font-bold absolute w-1/3 h-16 bg-white shadow-lg rounded-lg left-1/2 transition-transform duration-500 transform -translate-x-1/4" :class="isOver ? 'translate-y-2' : '-translate-y-16'">
		<div class="h-full flex flex-col justify-center">Just drag and drop your files here!</div>
	</div>
	<div v-if="this.file.length > 0" class="fixed h-full w-full bg-gray-900 bg-opacity-50">
		<div class="min-w-screen min-h-screen bg-gray-900 flex items-center justify-center px-5 py-5 bg-opacity-50 transform -translate-x-44">
			<div class="flex flex-col bg-gray-100 text-gray-500 rounded-3xl shadow-xl w-full" style="max-height:300px;max-width:1000px">
				<div class="pl-7 mt-7 text text-xl font-bold pb-2 border-b-2 border-gray-300 mx-5">Uploading {{total}} file(s)</div>
				<div class="flex items-center" style="min-height:240px">
					<div class="flex w-full justify-around">
						<div class="flex flex-col">
							<div class="flex mb-2 items-center" v-for="(elm, idx) in file" :key="idx">
								<font-awesome-icon :icon="['fas', get_file_type_icon(elm.type)]" size="lg" class="mr-5"/>
								<p>{{elm.name}}</p>
							</div>
						</div>
						<div class="my-auto flex loader ease-linear rounded-full border-8 border-t-8 border-gray-200 h-24 w-24"></div>
					</div>
				</div>
			</div>
		</div>
	</div>
</section>	
</template>

<script>
import axios from 'axios'
 
export default {

	data() {
		return {
			file: [],
			isOver: false,
			mounted: false,
			total: 0,
			files: [],
			selected: null,
			selectedData : {
				filename: "",
				timestamp: null,
				type: ""
			},
			downloading: false,
			done: false
		}
	},
	computed: {
		classes() {
			return {
				selected: ""
			}
		},
	},
	methods: {
		async addFile(elm) {
			this.isOver = false;
			this.upload = true;
			this.file = elm.dataTransfer.files;
			this.total = this.file.length;
			if(!this.file.length > 0) return;
			let formData = new FormData();
			for(var j=0 ; j < this.file.length ; j++) {
				formData.append('files', this.file[j]);
			}
			try {
				await axios.post('http://localhost:3000/api/upload', formData).then(() => {
					this.file = [];
					this.getAllFiles();
					this.total = 0;
				})
			} catch (err) {
				console.log(err);
			}
		},
		get_file_type_icon(type) {
			var domain = type.split("/")[0];
			if(domain == 'image') return 'file-image';
			else if(domain == 'audio') return 'file-audio';
			else if(domain == 'video') return 'file-video';
			else return 'file-alt';

		},
		async getAllFiles() {
			console.log("getAllFiles triggered")
			const res = await fetch("http://localhost:3000/api/get/files-metadata");
			const data = await res.json();
			this.files = data.files;
			this.selected=null;
		},
		select(file) {
			this.selected = file;
			this.done = false;
			this.downloading = false;
		},
		async download() {
			this.downloading = true;
			try {
				await axios.post('http://localhost:3000/api/download', this.selected).then(() => {
					console.log("Downloaded");
					this.done = true;
				})
			} catch (err) {
				console.log(err);
			}
		}

	},
	mounted() {
		this.$refs.drag.addEventListener("dragover", () => {
			this.isOver = true; // add class on drag over
		});
		this.$refs.drag.addEventListener("dragleave", () => {
			this.isOver = false; // remove class on drag leave
		});
		this.getAllFiles();
		this.selected = null;
		this.selectedData = {
				filename: "",
				timestamp: null,
				type: ""
			}
		this.mounted = true; 

	},
	watch: {
		selected: function () {
			if (this.selected) {
				const date = new Date(this.selected.timestamp * 1000);
				this.selectedData.filename = this.selected.filename;
				this.selectedData.timestamp = "" + date.getFullYear() + "-" + ((date.getMonth() + 1) > 9 ? '' : '0') + (date.getMonth() + 1) + "-" + (date.getDate() > 9 ? '' : '0') + date.getDate() + " " + (date.getHours() > 9 ? '' : '0') + date.getHours() + ":" +  (date.getMinutes() > 9 ? '' : '0') + date.getMinutes() + ":" +  (date.getSeconds() > 9 ? '' : '0') + date.getSeconds()
				this.selectedData.type = this.selected["mime-type"];
			}
		},
		done: function () {
			if (this.done) {
				setTimeout(() => {
					this.downloading = false;
					this.done = false;
				}, 2000)
			}
		}
	}
}
</script>

<style>
.loader {
  border-top-color: #3498db;
  -webkit-animation: spinner 1.5s linear infinite;
  animation: spinner 1.5s linear infinite;
}

@-webkit-keyframes spinner {
  0% { -webkit-transform: rotate(0deg); }
  100% { -webkit-transform: rotate(360deg); }
}

@keyframes spinner {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>