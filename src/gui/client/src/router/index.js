import Vue from "vue"
import Router from "vue-router"
import Storage from '@/views/Storage'
import Dashboard from '@/views/Dashboard'
import Settings from '@/views/Settings'

Vue.use(Router)

export const router = new Router({
	mode: 'history',
	routes: [
		{ path: "/storage", name: "storage", component: Storage, meta: { unprotected: true }},
		{ path: "/", name: "dashboard", component: Dashboard, meta: { unprotected: true }},
		{ path: "/settings", name: "settings", component: Settings, meta: { unprotected: true }},
	]
})