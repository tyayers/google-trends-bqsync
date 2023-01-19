<script lang="ts">
  import svelteLogo from './assets/svelte.svg'

  import AddTerms from "./lib/AddTerms.svelte";
  import Header from "./lib/Header.svelte";

  let showEditDialog = false;
  let terms: string = "ty";

  function saveTerms(event: CustomEvent) {
    terms = event.detail["terms"];
    showEditDialog = false;
  }


</script>

<Header on:showEditDialog={() => showEditDialog=true}/>

<div class="df">
  {terms}
</div>

{#if showEditDialog}
  <AddTerms on:cancel={() => {showEditDialog=false}} on:save={saveTerms} terms={terms}></AddTerms>
{/if}


<style>
  .df {
    width: 100vw;
    height: 100vh;
  }


</style>