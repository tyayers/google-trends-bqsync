<script lang="ts">
    import smedium from '../assets/bigquery_logo.png'
    import AddTerms from './AddTerms.svelte';


    import { createEventDispatcher } from 'svelte';

    const dispatch = createEventDispatcher();

    function showEditDialog() {
      dispatch('showEditDialog', {});
    }
  
   
  </script>
  
  <div class="h">
    <div class="hl">
      <div>
        <img class="hi" src={smedium} alt="Smedium logo" />
      </div>
      <div class="hsc">
        <div class="hsi">
          <svg class="hss" width="24" height="24" viewBox="0 0 24 24" fill="none"><path fill-rule="evenodd" clip-rule="evenodd" d="M4.1 11.06a6.95 6.95 0 1 1 13.9 0 6.95 6.95 0 0 1-13.9 0zm6.94-8.05a8.05 8.05 0 1 0 5.13 14.26l3.75 3.75a.56.56 0 1 0 .8-.79l-3.74-3.73A8.05 8.05 0 0 0 11.04 3v.01z" fill="currentColor"></path></svg>
          <input class="hsf" />
        </div>
      </div>
    </div>
    <div class="hr">
      <button class="sob" on:click={showEditDialog}>Edit</button>
    </div>
  </div>
  
  <style>
    .h {
      height: 57px;
      background-color: rgba(255, 255, 255, 1);
      /* width: 100vw; */
      border-bottom: solid 1px rgba(242, 242, 242, 1);
      padding: 0 24px;
      align-items: center;
      display: flex;
      /* top: 16px;
      position: relative; */
    }
  
    .hs {
      max-width: 1050px;
      margin: auto;
      border-bottom: 0px;
    }
  
    .hl {
      display: flex;
      flex: 1 0 auto;
    }
  
    .hr {
      display: flex;
      position: relative;
      right: 40px;
    }
  
    .hi {
      position: relative;
      top: 10px;
      width: 40px;
      cursor: pointer;
    }
    
    .hsc {
      display: flex;
      width: 240px;
      background: rgba(250, 250, 250, 1);
      border-radius: 20px;
      margin: 10px 5px 10px 16px;
    }
  
    .hsi {
      margin: 0px 12px 0px 12px;
      padding: 4px 0px 0px 0px;
      color: darkgray;
      display: flex;
    }
  
    .hss {
      position: relative;
      top: 3px;
    }
  
    .hsf {
      position: relative;
      top: -3px;
      padding: 10px 20px 10px 0;
      background-color: transparent;
      outline: none;
      border: none;
      color: rgba(41,41,41,1);
      line-height: 20px;
      font-size: 14px;
    }
  
    .wc {
      font-size: 14px;
      align-items: center;
      display: flex;
      font-weight: 400;
      line-height: 20px;
    }
  
    .wl {
      
      color: rgba(117, 117, 117, 1);
      display: flex;
      margin-right: 32px;
    }
  
    .wlt {
      margin-left: 8px;
    }
  
    .sob {
      cursor: pointer;
      border-radius: 99em;
      border-width: 1px;
      border-style: solid;
      border-color: rgb(242, 242, 242);
      text-decoration: none;
      background: white;
      fill: rgba(255, 255, 255, 1);
      padding: 7px 16px 9px;
      color: black;
      line-height: 20px;
      font-size: 14px;
      font-weight: 400;
      min-width: 89px;
    }
    </style>