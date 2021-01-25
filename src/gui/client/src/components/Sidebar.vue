<template>
	<!-- <section class="flex "> -->
		<div class="flex flex-col flex-shrink-0 h-screen w-96">
			<div class="relative flex flex-col flex-grow pb-4 overflow-y-auto z-0 bg-gradient-to-b from-blue-400 to-blue-800">
				<div class="flex items-center flex-shrink-0 justify-center my-10 mx-16">
					<img class="w-auto" :src="require('@/assets/logo.png')" alt="Logo">
				</div>
				<div>
					<div class="select-none mx-8 p-1 text-opacity-100 text-center rounded-md" :class="classes.connection"><span>IPFS {{this.id ? "connected to" : "disconnected from"}} network</span></div>	
				</div>
				<nav class="mt-5 flex-1 flex flex-col overflow-y-auto" aria-label="Sidebar">
					<div class="px-2 space-y-1">
						<router-link exact class="group flex items-center px-2 py-2 text-lg leading-6 font-medium rounded-md text-opacity-75 text-white hover:text-opacity-100 hover:bg-black hover:bg-opacity-20" to="/">
							<i class="ml-4 mr-4 text-opacity-70 text-white"></i>
							Dashboard
						</router-link>
						<router-link exact class="group flex items-center px-2 py-2 text-lg leading-6 font-medium rounded-md text-opacity-75 text-white hover:text-opacity-100 hover:bg-black hover:bg-opacity-20" to="/storage">
							<i class="ml-4 mr-4 text-opacity-70 text-white"></i>
							Storage
						</router-link>
						<router-link exact class="group flex items-center px-2 py-2 text-lg leading-6 font-medium rounded-md text-opacity-75 text-white hover:text-opacity-100 hover:bg-black hover:bg-opacity-20" to="/drive">
							<i class="ml-4 mr-4 text-opacity-70 text-white"></i>
							File Tracker
						</router-link>
					</div>
				</nav>
			</div>
		</div>
	<!-- </section> -->
</template>


<script>
export default {
	data() {
		return {
			id: null,
			polling: null,

		}
	},
	computed: {
		classes() {
			return {
				connection: this.id ? "text-green-700 bg-green-400" : "text-red-700 bg-red-400"
			}
		}
	},
	methods: {
		async getIpfsId() {
			const res = await fetch("http://localhost:3000/api/get/ipfs-id");
			const data = await res.json();
			if (res.status == 200)
				this.id = data.id;
			else
				this.id = null
		},
	},
	mounted() {
		this.polling = setInterval(() => {
			this.getIpfsId();
		}, 3000);
	},
	beforeDestroy () {
		clearInterval(this.polling)
	},
}
</script>