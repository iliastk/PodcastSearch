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
            <input
              v-model="selectedQuery"
              type="text"
              id="query"
              class="form-control"
            />

            <div class="interval">
              <label for="interval">Duration</label>
              <select
                v-model="selectedInterval"
                id="interval"
                class="form-control"
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
      v-if="matches.length"
      class="row mt-5"
    >
      <div class="col">
        <PodcastCard
          v-for="match in matches"
          :key="match"
          :match="match"
        />
      </div>
    </div>
  </div>
</div>
</template>

<script>
import axios from 'axios';

import Header from './components/layouts/Header';
import PodcastCard from './components/PodcastCard';

export default {
  components: {
    Header,
    PodcastCard,
  },
  data() {
    return {
      selectedQuery: '',
      selectedInterval: '30 seconds',
      intervals: ['30 seconds', '1 minute', '2 minutes', '3 minutes', '4 minutes'],
      matches: [],
    };
  },
  computed: {
    noFormData() {
      return !this.selectedQuery;
    },
    translateDuration() {
      let durationValue = 0;

      switch (this.selectedInterval) {
        case '30 seconds':
          durationValue = 0;
          break;
        case '1 minute':
          durationValue = 1;
          break;
        case '2 minutes':
          durationValue = 4;
          break;
        case '3 minutes':
          durationValue = 6;
          break;
        case '4 minutes':
          durationValue = 8;
          break;
        default:
          durationValue = 0;
          break;
      }

      return durationValue;
    },

  },
  methods: {
    async searchData() {
      const params = {
        query: this.selectedQuery,
        duration: this.translateDuration,
      };

      const elasticsearchData = (await axios.get('http://localhost:3000/results', { params })).data;

      /* ELASTICSEARCHDATA
        confidence: 0.854689359664917
        transcript: "bla bla bla Michael Jackson bla bla bla"
        words: [
          {
            endTime: "1.100s"
            startTime: "0.900s"
            word: "Do"
          },
          {
            endTime: "1.100s"
            startTime: "1.100s"
            word: "you"
          },
          {
            endTime: "1.400s"
            startTime: "1.100s"
            word: "think"
          }
        ]
      */

      this.matches = [];

      elasticsearchData.forEach((retrieve) => {
        this.matches.push({
          title: retrieve.episode_name,
          transcripts: retrieve.matches.map(match => match.transcript),
          startTime: retrieve.matches[0].words[0].startTime,
          source: retrieve.show_name,
        });
      });
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

