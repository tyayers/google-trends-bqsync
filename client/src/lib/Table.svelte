<script lang="ts">
  import type {TrendsTerm} from '$lib/Types'

  // export let termData: TrendsTerm;


</script>

<table class="t">
  <thead>
      <tr>
          <th>Name</th>
          <th>Points</th>
      </tr>
  </thead>
  <tbody>
      <tr>
          <td>Dom</td>
          <td>6000</td>
      </tr>
      <tr class="active-row">
          <td>Melissa</td>
          <td>5150</td>
      </tr>

      <!-- and so on... -->
  </tbody>
</table>


<!-- <div class="c">
  <div class="tn" contenteditable=true>{termData.name}</div>
  <div class="ts">{termData.score}</div>
  <div class="tu">{termData.lasteUpdate}</div>
</div> -->

<style>
  .c {
    display: flex;
    height: 50px;
    border-bottom: solid 1px rgba(242, 242, 242, 1);
    vertical-align: center;
    padding-top: 20px;
    padding-left: 20px;
    padding-right: 20px;
    /* padding-bottom: 10px; */
  }

  .tn {
    display: flex;
    flex: 1 0 auto;
  }

  .ts {
    display: flex;
    flex: 1 0 auto;
  }

  .tu {
    display: flex;
    position: relative;
    right: 10px;
  }

  .t {
    border-collapse: collapse;
    margin: 0;
    width: 100%;
    font-size: 0.9em;
    font-family: sans-serif;

    /* box-shadow: 0 0 20px rgba(0, 0, 0, 0.15); */
  }

  .t thead {
    box-sDizing: border-box;
    background-color: rgb(248 248 248);
  }

  .t thead tr {
    border-bottom: 1px solid #f2f2f2;
    text-align: left;
  }

  .t thead tr th {
    /* font-family: Roboto-Bold; */
    font-size: 13px;
    color: #565656;
    line-height: 1.4;
    text-transform: uppercase;
    padding-top: 8px;
    padding-bottom: 8px;
  }

  .t tbody tr {
    border-bottom: 1px solid #f2f2f2;
    box-sizing: border-box;
  }
  
  .t tbody tr td {
    color: #999;
    font-size: 15px;
    line-height: 1.4;
    padding-top: 16px;
    padding-bottom: 16px;
    font-weight: unset;
    padding-right: 10px;
  }

/* 
  .t th,
  .t td {
      padding: 12px 15px;
  }

  .t tbody tr {
      border-bottom: 1px solid #dddddd;
  }

  .t tbody tr:nth-of-type(even) {
      background-color: #f3f3f3;
  }

  .t tbody tr:last-of-type {
      border-bottom: 2px solid #009879;
  }

  .t tbody tr.active-row {
      font-weight: bold;
      color: #009879;
  } */
</style>
