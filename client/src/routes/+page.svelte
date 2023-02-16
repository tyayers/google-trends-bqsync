<script lang="ts">
  import { onMount } from "svelte";

  import type {TrendsTerm, TrendsData, TableColumn} from '$lib/Types'
  import AddTerms from "$lib/AddTerms.svelte";
  import Header from "$lib/Header.svelte";
  import TabBar from "$lib/TabBar.svelte";
  import Loading from "$lib/Loading.svelte";
  
  import Table from "$lib/Table.svelte";

  let showEditDialog = false;
  let showLoading = true;
  let geos: string[] = []
  let selectedGeo: string = ""
  let terms: TrendsTerm[] = [];
  let selectedData: TrendsData[] = [];
  
  let columns: TableColumn[] = [
    {
      Header: "Name",
      accessor: "name"
    },
    {
      Header: "Score",
      accessor: "score"
    },
    {
      Header: "LastUpdate",
      accessor: "lastUpdate"
    },
    {
      Header: "DailyGrowth",
      accessor: "dailyChange"
    },
    {
      Header: "WeeklyGrowth",
      accessor: "weeklyChange"
    },
    {
      Header: "MonthlyGrowth",
      accessor: "monthlyChange"
    }
  ]

  onMount(async function () {
    fetch("http://localhost:8080/trends/cold&flu")
    .then(response => response.json())
    .then(data => {
      terms = data["terms"] as TrendsTerm[]
      geos = data["geos"]
      
      if (geos.length > 0)
        selectedGeo = geos[0]
        setData()
      
      setTimeout(() => {
        showLoading = false;
      }, 1000)
    });

    //terms = (await response.json())["terms"] as TrendsTerm[];
    
    console.log(terms);
    //posts = data;
  });

  function saveTerms(event: CustomEvent) {
    terms = event.detail.terms;
    console.log(terms);
    
    fetch("http://localhost:8080/trends/cold&flu",
    {
      method: "POST",
      body: JSON.stringify({
        "terms": terms
      })
    })
    .then(response => response.json())
    .then(data => {
      console.log(data)
    });
    
    showEditDialog = false;
  }
  
  function refresh() {
    fetch("http://localhost:8080/trends/cold&flu/refresh",
    {
      method: "POST",
      body: JSON.stringify({
        "terms": terms
      })
    })
    .then(response => response.json())
    .then(data => {
      console.log(data)
      
      terms = data["terms"]
    });
  }
  
  function setData() {
    let new_data: TrendsData[] = []
    for (const term of terms) {
      if (term.data) {
        for (const row of term.data) {
          if (row.geo === selectedGeo) {
            new_data.push(row)
          }
        }
      }
      else
        console.log("No data found for term " + term.name)
    }
    
    selectedData = new_data
  }
  
  function selectTab(event: CustomEvent) {
    selectedGeo = event.detail.name;
    setData()
  }
</script>

<Header on:showEditDialog={() => showEditDialog=true} on:refresh={refresh}/>



<div>
  {#if showLoading}
    <Loading />
  {:else}
    <TabBar class="tabbar-sticky" tabs={geos} selectedTab={selectedGeo} on:tabSelect={selectTab} />
    <Table columns={columns} data={selectedData} /> 
  {/if}
  
 
</div>

{#if showEditDialog}
  <AddTerms on:cancel={() => {showEditDialog=false}} on:save={saveTerms} terms={terms}></AddTerms>
{/if}


<style>

  .tabbar-sticky {
    position: sticky; top: 100;
  }


</style>