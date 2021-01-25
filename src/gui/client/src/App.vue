<template>
<div class="flex flex-row bg-gray-50">
	<div class="">
		<Sidebar />
	</div>
	<router-view />
</div>	
</template>

<script>
import Sidebar from '@/components/Sidebar'

export default {
	name: 'App',
	components: {
		Sidebar,
	},
}
</script>