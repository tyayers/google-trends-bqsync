<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  const dispatch = createEventDispatcher();
  
  function cancel() {
		dispatch('cancel', {});
  }

  const save = () => {
    dispatch('save', {
      terms: terms
    });
  }

  export let terms = ``
</script>

<div class="sc" on:keydown={() => {}} on:click={cancel}>
  <div class="sp" on:keydown={() => {}} on:click|stopPropagation={() => {}}>
    <h2>Edit search</h2>
    <textarea bind:value={terms}></textarea>
    <button class="sob" on:click={save}>Save</button>
  </div>

</div>

<style>
  .sc {
    position: fixed;
    background-color: rgba(255, 255, 255, 0.95);
    top: 0px;
    left: 0px;
    width: 100vw;
    height: 100vw;
    animation: 300ms cubic-bezier(0.25, 0.1, 0.25, 1) 0s 1 normal forwards running k3;
    transform-origin: center bottom;
    align-items: center;
    justify-content: center;
    
    /* display: flex; */
  }
  .sp {
    width: 678px;
    text-align: center;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    display: flex;
    /* flex: 1 0 auto; */
    position: relative;
    
    animation: 300ms cubic-bezier(0.25, 0.1, 0.25, 1) 0s 1 normal forwards running k3;
    padding: 44px 56px;
    background: rgb(255, 255, 255);
    box-shadow: rgb(0 0 0 / 15%) 0px 2px 10px;
    border-radius: 4px;
    display: block;
    max-height: 695px;
    height: 100%;
    flex-direction: row;
    margin: 0;
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
  }
  textarea {
    height: 85%;
    width: 100%;
    border-width: 1px;
    border-color: black;
  }
  .so {
    margin-top: 50px;
  }
  .sob {
    width: 212px;
    border-color: rgb(168, 168, 168);
    text-align: left;
    padding: 6px 12px 8px 16px;
    background: rgb(255, 255, 255);
    border-style: solid;
    border-width: 1px;
    border-radius: 99em;
    color: rgba(41, 41, 41, 1);
    font-size: 14px;
    font-family: sohne, "Helvetica Neue", Helvetica, Arial, sans-serif;
    font-weight: 400;
    display: inline-block;
    box-sizing: border-box;
    cursor: pointer;
    position: absolute;
    right: 20px;
    bottom: 20px;
    width: 75px;
    text-align: center;
  }
  .sobt {
    align-items: center;
    text-align: left;
    line-height: 20px;
    display: flex;
  }
  .sobti {
    margin-right: 8px;
    vertical-align: middle;
  }

  h2 {
    font-family: Arial, Helvetica, sans-serif;
  }
</style>