<!-- eslint-disable vue/no-v-html -->
<template>
  <div class="full-width little-space-bottom">
    <!--Card for streams-->
    <div class="card mention-stream-view-card column">
      <div class="mention-content relative stream-content column no-wrap border-color-cyan">
        <div class="row no-wrap">
          <div class="little-space full-width">
            <div class="row no-wrap justify-between">
              <div class="column">
                <strong
                  v-if="match.title"
                  class="block bigger2 e2e-mention-title"
                >
                  {{ match.title }}
                </strong>

                <div class="row no-wrap justify-start items-start q-mb-md">
                <!--On mobile, we display logo with the content to save space-->
                <img
                  :src="image"
                  class="logo"
                  alt="Source logo"
                >
                <div class="column col  flex-basis-100">
                  <span class="alternate q-mt-xs">
                    Source: {{ match.source }}
                  </span>
                  <div class="softer">
                    <span>
                      Mention said around {{ match.startTime }}
                    </span>
                  </div>
                </div>
              </div>
              </div>
            </div>
            <div
              v-for="transcript in match.transcripts"
              :key="transcript"
              class="tiny-space"
            >
              {{ transcript }}
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
// eslint-disable-next-line
import image from "/Users/iliastalidi/Documents/GitHub/PodcastSearch/frontend-task2/src/assets/podcast-icon-6.png"

export default {
  name: 'PodcastCard',
  props: {
    match: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      image,
    };
  },
  computed: {
    formatSeconds() {
      return 0;
    },
  },
};
</script>

<style>
  .mention-content {
    border-left: 5px solid #2ad2f0e0;
  }

  .little-space {
    margin-left: 15px;
  }

  .little-space-bottom {
    margin-bottom: 10px;
  }

  .tiny-space {
    margin-top: 10px;
    margin-bottom: 5px;
  }

  .e2e-mention-title {
    word-break: break-word;
    letter-spacing: 0.02em;
    margin-left: 15px;
  }

  .stream-content {
      border-radius: 4px;
      padding: 15px 10px 20px 15px;
  }

  .card {
    border-radius: 4px;
  }

  .p {
    margin-bottom: 5px;
    line-height: 20px;
  }

  .mention-stream-view-card {
    border-top: 1px solid ds-denim-3;
    border-right: 1px solid ds-denim-3;
    border-bottom: 1px solid ds-denim-3;
  }

  .softer {
    color: #A5A5A5;
  }

  .logo {
    width: 29px;
    height: 30px;
    margin-top: 10px;
    margin-left: 32px;
    color: #767676;
  }
</style>
