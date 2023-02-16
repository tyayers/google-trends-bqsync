<script lang="ts">
  import type {TrendsTerm, TableColumn} from '$lib/Types'
  // import { each } from 'svelte/internal';

  // export let termData: TrendsTerm;
  export let columns: TableColumn[] = [];
  export let data: TrendsTerm[] = [];
  
</script>

<table class="t">
  <thead>
      <tr>
          {#each columns as col}
            <th>{col.Header}</th>
          {/each}
      </tr>
  </thead>
  <tbody>
      {#each data as row}
        <tr>
          {#each columns as col}
            {#if row[col["accessor"]] != undefined}
              <td>{row[col["accessor"]]}</td>
            {:else}
              <td></td>
            {/if}
          {/each}
        </tr>      
      {/each}
  </tbody>
</table>

<style>

  .t {
    border-collapse: collapse;
    margin: 0;
    width: 95vw;
    margin: 20px;
    border-radius: 25px;
    font-size: 0.9em;
    font-family: sans-serif;

    /* box-shadow: 0 0 20px rgba(0, 0, 0, 0.15); */
  }

  .t thead {
    box-sizing: border-box;
    background-color: rgb(248 248 248);
    border-radius: 10% 10% 0% 0%;
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
