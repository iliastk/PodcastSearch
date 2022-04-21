<script>
import { Bar } from 'vue-chartjs';

export default {
  extends: Bar,
  props: {
    label: {
      type: Array
    },
    data: {
      type: Array,
      required: true,
    },
    options: {
      type: Object,
      required: true,
    },
  },
  
  mounted() {
    this.renderChart({
      labels: this.label,
      datasets: this.data,
    },
    this.options,
    );
  },
};

</script>
