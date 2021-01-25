<template>
<section class="w-screen transition-colors" ref="drag" :class="isOver ? 'bg-blue-200 shadow-inner' : 'bg-transparent'" v-cloak @drop.prevent="addFile" @dragover.prevent>
	<div class="text-center font-bold absolute w-1/3 h-16 bg-white shadow-lg rounded-lg left-1/2 transition-transform duration-500 transform -translate-x-1/4" :class="isOver ? 'translate-y-2' : '-translate-y-16'">
		<div class="h-full flex flex-col justify-center">Just drag and drop your files here!</div>
	</div>
	<div v-if="this.file.length > 0" class="min-w-screen min-h-screen bg-gray-900 flex items-center justify-center px-5 py-5 bg-opacity-50">
		<div class="flex flex-col bg-gray-100 text-gray-500 rounded-3xl shadow-xl w-full overflow-hidden" style="min-height:300px;max-width:1000px">
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
		}
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

		}
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