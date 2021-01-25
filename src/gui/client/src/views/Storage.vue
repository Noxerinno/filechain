<template>
<section class="w-screen transition-colors" ref="drag" :class="isOver ? 'bg-blue-200 shadow-inner' : 'bg-transparent'" v-cloak @drop.prevent="addFile" @dragover.prevent>
	<div class="text-center font-bold absolute w-1/3 h-16 bg-white shadow-lg rounded-lg left-1/2 transition-transform duration-500 transform -translate-x-1/4" :class="isOver ? 'translate-y-2' : '-translate-y-16'">
		<div class="h-full flex flex-col justify-center">Just drag and drop your files here!</div>
	</div>
	<div v-if="this.file.length > 0" class="min-w-screen min-h-screen bg-gray-900 flex items-center justify-center px-5 py-5 bg-opacity-50">
		<div class="flex flex-col bg-gray-100 text-gray-500 rounded-3xl shadow-xl w-full overflow-hidden" style="min-height:300px;max-width:1000px">
			<div class="pl-7 mt-7 text text-xl font-bold pb-2 border-b-2 border-gray-300 mx-5">Uploading files...</div>
			<div class="mx-auto my-auto">
				<div class="mb-2" v-for="(elm, idx) in file" :key="idx">{{elm.name}}  - {{elm.type}}</div>
				<!-- <div class="mb-2">Mon fichier - le type</div>
				<div class="mb-2">Mon fichier - le type</div>
				<div class="mb-2">Mon fichier - le type</div> -->
			</div>
		</div>
	</div>
	<div class="">
		<!-- <div class="flex flex-col w-80 text-center h-80 bg-gray-100 mx-auto mt-20 justify-center align-middle">
			{{this.output}}
		</div> -->
		<!-- <div class="large-12 medium-12 small-12 cell">
		<label for="file">File
			<input multiple type="file" id="file" ref="file" v-on:change="handleFileUpload()"/>
		</label>
			<button v-on:click="submitFile()">Submit</button>
		</div> -->
	</div>
</section>	
</template>

<script>
import axios from 'axios'

export default {

	data() {
		return {
			file: [],
			// output: "Drop your file here",
			isOver: false,
			mounted: false,
		}
	},
	methods: {
		async addFile(elm) {
			this.isOver = false;
			this.upload = true;
			this.file = elm.dataTransfer.files;
			console.log(this.file);
			if(!this.file.length > 0) return;
			let formData = new FormData();
			for(var j=0 ; j < this.file.length ; j++) {
				formData.append('files', this.file[j]);
			}
			try {
				await axios.post('http://localhost:3000/api/upload', formData)
				.then(() => {
					// this.output = response.data.content;
					this.file = [];
				});
			} catch (err) {
				console.log(err);
			}
		},
		handleFileUpload(){
			for(var i=0 ; i < this.$refs.file.files.length ; i++) {
				this.file.push(this.$refs.file.files[i]);
				console.log(this.file);
			}
		},
		async submitFile(){
			let formData = new FormData();
			for(var i=0 ; i < this.file.length ; i++) {
				formData.append('file['+i+']', this.file[i]);
			}
			try {
				await axios.post('http://localhost:3000/api/upload', formData);
			} catch (err) {
				console.log(err);
			}
		},
	},
	mounted() {
		this.$refs.drag.addEventListener("dragover", () => {
			this.isOver = true; // add class on drag over
		});
		this.$refs.drag.addEventListener("dragleave", () => {
			this.isOver = false; // remove class on drag leave
		});
		this.mounted = true; 
	}
}
</script>