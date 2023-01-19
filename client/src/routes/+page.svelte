<script lang="ts">
  import { onMount } from "svelte";

  import type {TrendsTerm} from '$lib/Types'
  import AddTerms from "$lib/AddTerms.svelte";
  import Header from "$lib/Header.svelte";
  import Table from "$lib/Table.svelte";

  let showEditDialog = false;
  let terms: TrendsTerm[] = [];

  onMount(async function () {
    const response = await fetch("http://localhost:8080/trends/cold&flu");
    terms = (await response.json())["terms"] as TrendsTerm[];

    console.log(terms);
    //posts = data;
  });

  function saveTerms(event: CustomEvent) {
    terms = event.detail.terms;
    showEditDialog = false;
  }
</script>

<Header on:showEditDialog={() => showEditDialog=true}/>

<Table />

<div class="df">

  <!-- {#each terms as term}
    <TermLine termData={term}></TermLine>
  {/each} -->
</div>

{#if showEditDialog}
  <AddTerms on:cancel={() => {showEditDialog=false}} on:save={saveTerms} terms={terms}></AddTerms>
{/if}


<style>

  .df {
    width: 100vw;
    height: 100vh;

    font-family: Arial, Helvetica, sans-serif;
  }


</style>