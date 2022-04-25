<template>
<div>
  <Header />
  <div class="container">
    <div class="row mt-5">
      <div class="col">
        <div class="form-group">
          <div class="query-input">
            <label for="query">Query</label>
            <span class="soft">(Please enter a term to search)</span>
            <Input
              type="text"
              id="query"
              class="form-control"
              v-model="request.query"
            />

            <div class="interval">
              <label for="interval">Duration</label>
              <Select
                id="interval"
                class="form-control"
                v-model="selectedInterval"
              >
                <Option
                  v-for="interval in intervals"
                  :key="interval"
                >
                  {{ interval }}
                </Option>
              </Select>
            </div>
          </div>

          <div class="buttons">
            <Button
              class="btn btn-primary"
              :disabled="noFormData"
              @click="searchData"
            >
              Search
            </Button>
          </div>
          <span
            v-if="noFormData"
            class="error-message"
          >
            Please make sure all form elements are filled in
          </span>
        </div>
      </div>
    </div>
    <div
      v-if="dataSets.length"
      class="row mt-5"
      >
      <div class="col">
        <StackedChart
          :label="arrayDates"
          :data="dataSets"
          :options="chartOptions"
        />
      </div>
    </div>
  </div>
</div>
</template>

<script>
import 'vue-datetime/dist/vue-datetime.css';

import axios from 'axios';
import moment from 'moment';

import Header from './components/layouts/Header';
import StackedChart from './components/StackedChart';

export default {
  components: {
    StackedChart,
    Header,
  },
  data() {
    return {
      request: {
        query: '',
        before: '',
        after: '',
      },
      selectedInterval: '1 minute',
      intervals: ['10 seconds', '30 seconds', '1 minute', '2 minutes', '3 minutes', '4 minutes'],
      // minDatetime: '2019-08-01T00:00:00+10',
      // maxDatetime: '2019-08-31T23:59:59+10',
      datetime: '',
      dataSets: [],
      chartOptions: {
        responsive: true,
        maintainAspectRatio: false,
        legend: {
          position: 'right', // place legend on the right side of chart
        },
        scales: {
          xAxes: [{
            stacked: true,
            categoryPercentage: 1.0,
          }],
          yAxes: [{
            stacked: true,
          }],
        },
      },
    };
  },
  computed: {
    noFormData() {
      return !this.request.query;
    },
  },
  methods: {
    async searchData() {
      this.dataSets = [];
      const paramsValues = Object.values(this.request);

      const params = {
        query: paramsValues[0],
        // before: moment(paramsValues[1]).format('x'), // before: 1564617600000,
        // after: moment(paramsValues[2]).format('x'), // after: 1567295999000,
        interval: this.selectedInterval,
      };

      const elasticsearchData = (await axios.get('http://localhost:3000/results', { params })).data;

      const keys = Object.keys(elasticsearchData);

      const arrOnline = [];
      const arrTV = [];
      const arrRadio = [];
      const arrSocial = [];
      const arrPrint = [];
      const arrMagazine = [];
      this.arrayDates = [];
      let index = 0;

      keys.forEach((key) => {
        const date = key;
        this.arrayDates[index] = moment(key).format('DD/MM');

        const array = Object.values(elasticsearchData);
        const insideArray = array[index];
        index += 1;
        let i;

        for (i = 0; i < insideArray.length; i += 1) {
          switch (insideArray[i].key) {
            case 'Online':
              arrOnline.push({ date, label: insideArray[i].key, count: insideArray[i].doc_count });
              break;
            case 'TV':
              arrTV.push({ date, label: insideArray[i].key, count: insideArray[i].doc_count });
              break;
            case 'Radio':
              arrRadio.push({ date, label: insideArray[i].key, count: insideArray[i].doc_count });
              break;
            case 'Social':
              arrSocial.push({ date, label: insideArray[i].key, count: insideArray[i].doc_count });
              break;
            case 'Print':
              arrPrint.push({ date, label: insideArray[i].key, count: insideArray[i].doc_count });
              break;
            case 'Magazine':
              arrMagazine.push({
                date,
                label: insideArray[i].key,
                count: insideArray[i].doc_count,
              });
              break;
            default:
              // console.log('Err of type of medium');
          }
        }
      });

      this.dataSets = [
        {
          label: 'Online',
          borderColor: '#4E5E66',
          pointBorderColor: '#4E5E66',
          pointBackgroundColor: '#31E981',
          backgroundColor: '#31E981',
          data: arrOnline.map(d => d.count),
        },
        {
          label: 'Radio',
          borderColor: '#251F47',
          pointBorderColor: '#260F26',
          pointBackgroundColor: '#858EAB',
          backgroundColor: '#858EAB',
          data: arrRadio.map(d => d.count),
        },
        {
          label: 'TV',
          borderColor: '#784F41',
          pointBorderColor: '#784F41',
          pointBackgroundColor: '#BBE5ED',
          backgroundColor: '#BBE5ED',
          data: arrTV.map(d => d.count),
        },
        {
          label: 'Social',
          borderColor: '#190B28',
          pointBorderColor: '#190B28',
          pointBackgroundColor: '#E55381',
          backgroundColor: '#E55381',
          data: arrSocial.map(d => d.count),
        },
        {
          label: 'Print',
          borderColor: '#FF0000',
          pointBorderColor: '#FF0000',
          pointBackgroundColor: '#FF6347',
          backgroundColor: '#FF6347',
          data: arrPrint.map(d => d.count),
        },
        {
          label: 'Magazine',
          borderColor: '#f5bd1f',
          pointBorderColor: '#f5bd1f',
          pointBackgroundColor: '#f5bd1f',
          backgroundColor: '#f5bd1f',
          data: arrMagazine.map(d => d.count),
        },
      ];
    },
  },
};
</script>

<style>
  .query-input {
    margin: 20px;
  }
  .date-inputs {
    display: flex;
    flex-wrap: inherit;
    margin: 20px;
  }
  .soft {
    color: lightgrey;
  }
  .buttons {
    display: flex;
    justify-content: center;
  }
  .interval {
    margin-top: 10px;
  }
  .error-message {
    color: red;
    display: flex;
    justify-content: center;
    font-size: 12px;
    margin: 5px;
  }
  .standard-label {
    margin-right: 0.5rem;
    margin-left: 1rem;
    margin-top: 0.35rem;
  }
</style>

