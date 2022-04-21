// import router from './router';
import 'bootstrap/dist/css/bootstrap.css';
import TurbolinksAdapter from 'vue-turbolinks';
import Vue from 'vue';
import App from './App.vue';
import 'vue-datetime/dist/vue-datetime.css'
import { Datetime } from 'vue-datetime'

Vue.use(TurbolinksAdapter);
Vue.use(Datetime);
Vue.component('datetime', Datetime);

Vue.config.productionTip = false;
// Vue.component('app', App)
/*
document.addEventListener('turbolinks:load', () => {
  const app = new Vue({
    render: (h) => h(App),}).$mount('#app');
}) */


new Vue({
  render: (h) => h(App),
}).$mount('#app');
