<template>
<section v-if="mounted" class="">
	<div class="grid m-4 xl:m-10">
		<div class="bg-white shadow-lg rounded px-8 pt-6 pb-8 mx-auto xl:mx-24 mt-14 flex flex-col text-center">
			<div class="flex flex-col align-center items-center mx-12">
				<div class="text-grey-darker uppercase text-center font-bold mb-4">
					Settings
				</div>
				<div class="text-sm text-gray-600 mb-5">
					All files downloaded will be stored in the folder selected here. Don't forget to save in order to apply the changes.
				</div>
				<div class="flex w-full justify-between">
					<div class="flex flex-col w-4/5 mr-7">
						<input v-model="path" placeholder="Enter the path to your main directory here" class="outline-none text-sm text-gray-600 bg-gray-100 py-1 px-7 rounded-md select-none">
						<div :class="this.pathInfo ? 'opacity-100' : 'opacity-0'" class="transition-opacity">
							<div v-if="this.pathInfo == 'Problem'" class ="text-red-600 text-sm px-4 mt-1">
								Path invalid
							</div>
							<div v-else class ="text-green-600 text-sm px-4 mt-1">
								Success!
							</div>
						</div>
					</div>
					<button class="h-7 bg-blue-500 rounded-md px-6 text-white font-semibold ml-10 hover:bg-blue-600 focus:outline-none" v-on:click="submitPath()">Save</button>
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
			data: null,
			mounted: false,
			polling: null,
			path: "",
			pathInfo: null,
		}
	},
	methods: {
		async submitPath() {
			if(this.path == "") {
				this.pathInfo = "Empty";
				return
			}
			await axios.post('http://localhost:3000/api/submitPath', {path: this.path}).then((res) => {
			if (res.data.valid)
				this.pathInfo = "Success"
			else
				this.pathInfo = "Problem";
			setTimeout(() => {
				this.pathInfo = null;
			}, 5000);
		})
			
		}
		// async getIpfsData() {
		// 	const res = await fetch("http://localhost:3000/api/get/ipfs-data");
		// 	const data = await res.json();
		// 	if (res.status == 200 && !data.errno)
		// 		this.data = data;
		// 	else
		// 		this.data = null;
		// },
	},
	async mounted() {
		const res = await fetch("http://localhost:3000/api/get/path");
		const data = await res.json();
		this.path = data.path;
		this.mounted = true;
	},
}
</script>