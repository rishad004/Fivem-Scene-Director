function spawn() {
    fetch(`https://${GetParentResourceName()}/action`, {
        method: 'POST',
        body: JSON.stringify({ type: "spawnActor", id: 1 })
    })
}

function play() {
    fetch(`https://${GetParentResourceName()}/action`, {
        method: 'POST',
        body: JSON.stringify({ type: "playTimeline" })
    })
}