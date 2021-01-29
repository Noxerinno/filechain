<template>
<div class="absolute overflow-hidden w-full">
	<div class="flex flex-row bg-gray-50">
		<div class="ml-96 w-full h-screen">
			<router-view />
		</div>
		<div class="fixed">
			<Sidebar />
		</div>
	</div>	
</div>

</template>

<script>
import Sidebar from '@/components/Sidebar'

export default {
	name: 'App',
	title: 'FileChain',
	components: {
		Sidebar,
	},
}
</script>