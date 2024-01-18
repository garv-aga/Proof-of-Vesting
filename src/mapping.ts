 //@ts-ignore
import { require } from "@hyperoracle/zkgraph-lib";
import { Bytes, Block, Event } from "@hyperoracle/zkgraph-lib";

let addr = Bytes.fromHexString('0x9D8e38b52F08FD7b0fc5C04460CdFC3AC30ce7bf');
let esig_start = Bytes.fromHexString("0xdbac898e65d6e2eb500e4a2721266f81bbe66f2b88f851d052acf9cbe5828d38");
let esig_end = Bytes.fromHexString("0x92556804021c81436e5a9adb2ccb99b74088418f5ee423d28553ace96b6fe7bd");

export function handleBlocks(blocks: Block[]): Bytes {
  // init output state
  let state: Bytes;

  // #1 can access all (matched) events of the latest block
  let events: Event[] = blocks[0].events;

  // #2 also can access (matched) events of a given account address (should present in yaml first).
  // a subset of 'events'
  let eventsByAcct: Event[] = blocks[0].account(addr).events;

  // #3 also can access (matched) events of a given account address & a given esig  (should present in yaml first).
  // a subset of 'eventsByAcct'
  let eventsByAcctEsigStart: Event[] = blocks[0].account(addr).eventsByEsig(esig_start)
  let eventsByAcctEsigEnd: Event[] = blocks[0].account(addr).eventsByEsig(esig_end)

  // require match event count > 0
  require(eventsByAcctEsigStart.length > 0 && eventsByAcctEsigEnd.length > 0)

  // this 2 way to access event are equal effects, alway true when there's only 1 event matched in the block (e.g. block# 2279547 on sepolia).
  require(
    events[0].data == eventsByAcct[0].data 
    && events[0].data == eventsByAcctEsigStart[0].data && events[0].data == eventsByAcctEsigEnd[0].data
  );

  // set state to the address of the 1st (matched) event, demo purpose only.
  state = events[0].address;

  return state
}