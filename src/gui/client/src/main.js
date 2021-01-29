import Vue from 'vue'
import App from './App.vue'
import '@/assets/index.css';
import { router } from "./router/index"

import {library} from '@fortawesome/fontawesome-svg-core'
import {fas} from '@fortawesome/free-solid-svg-icons'
import {FontAwesomeIcon} from '@fortawesome/vue-fontawesome'
import titleMixin from './mixins/titleMixin'

library.add(fas);
Vue.component('font-awesome-icon', FontAwesomeIcon);
Vue.mixin(titleMixin)
Vue.config.productionTip = false
// Vue.use(VueAxios, axios)

new Vue({
  router,
  render: h => h(App),
}).$mount('#app')
