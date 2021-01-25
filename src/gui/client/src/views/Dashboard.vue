<template>
<section v-if="mounted" class="w-screen">
	<div v-if="this.data" class="grid m-4 xl:m-10">
		<div class="bg-white shadow-lg rounded px-8 pt-6 pb-8 mx-auto xl:mx-24 mt-14 flex flex-col">
			<div class="flex flex-col align-center">
				<div class="text-grey-darker uppercase text-center font-bold mb-4">
					IPFS peer
				</div>
				<div class="text-sm text-gray-600 mb-2 mx-auto">
					<div class="flex"> 
						<!-- grid grid-cols-8 -->
						<div class="mr-14">Peer ID:</div>
						<div>{{this.data.id}}</div>
					</div>
					<div class="flex">
						<div class="mr-9">IP Address:</div>
						<div>{{this.data.address}}</div>
					</div>
					<div class="flex">
						<div class="mr-3">Agent Version:</div>
						<div>{{this.data.agentVersion}}</div>
					</div>
				</div>
			</div>
		</div>
		<div class="bg-white shadow-lg rounded px-8 pt-6 pb-8 mx-auto xl:mx-24 mt-14 flex flex-col">
			<div class="flex flex-col align-center">
				<div class="text-grey-darker text-md uppercase text-center font-bold mb-4">
					Swarm peers
				</div>
				<div class="-mx-4 sm:-mx-8 px-4 sm:px-8 py-4 overflow-x-auto">
					<div v-if="data.peers.length == 0" class="flex justify-center text-sm text-gray-600">There is no other node in this network...</div>
					<div v-else class="inline-block min-w-full shadow rounded-lg overflow-hidden">
					<table class="min-w-full leading-normal">
						<thead>
						<tr class="border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
							<th
							class="px-5 py-3">
							Peer ID
							</th>
							<th
							class="px-5 py-3">
							IP Address
							</th>
						</tr>
						</thead>
						<tbody>

						<tr v-for="(peer, idx) in this.data.peers" :key="idx">
							<td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
								<div class="ml-3">
									<p class="text-gray-900 whitespace-no-wrap">{{peer.peer}}</p>
								</div>
							</td>
							<td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
								<p class="text-gray-900 whitespace-no-wrap">{{peer.address}}</p>
							</td>
						</tr>
						</tbody>
					</table>
				</div>
				</div>
			</div>
		</div>
	</div>
	<div v-else class="flex flex-col text-center text-red-700 font-bold text-3xl h-screen justify-center">
		IPFS container disconnected from the network
	</div>
</section>
</template>

<script>
export default {
	data() {
		return {
			data: null,
			mounted: false,
			polling: null
		}
	},
	methods: {
		async getIpfsData() {
			const res = await fetch("http://localhost:3000/api/get/ipfs-data");
			const data = await res.json();
			if (res.status == 200 && !data.errno)
				this.data = data;
			else
				this.data = null;
		},
	},
	async mounted() {
		await this.getIpfsData();
		console.log(this.data);
		this.polling = setInterval(() => {
			this.getIpfsData();
		}, 3000);
		this.mounted = true;
	},
	beforeDestroy () {
		clearInterval(this.polling)
	},
}
</script>