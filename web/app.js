// ========================
// UTILITIES
// ========================
function post(endpoint, data) {
    return fetch(`https://${GetParentResourceName()}/${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {})
    })
}

// ========================
// UI TOGGLE
// ========================
window.addEventListener('message', (event) => {
    const data = event.data

    if (data.action === 'toggle') {
        document.getElementById('app').style.display = data.state ? 'flex' : 'none'
        if (data.state) {
            loadAnimations()
            loadTimeline()
            loadScenes()
        }
    }

    if (data.action === 'sceneList') {
        sceneList = data.scenes || []
        renderScenes(document.getElementById('sceneSearch').value || '')
    }

    if (data.action === 'actorSpawned') {
        document.getElementById('actorCount').textContent = 'Actors in scene: ' + data.count
    }

    if (data.action === 'actorSelected') {
        const label = document.getElementById('selectedActorLabel')
        if (data.index != null) {
            label.textContent = 'Selected: Actor ' + (data.index + 1)
            label.style.color = '#8fcf8f'
        } else {
            label.textContent = 'No actor selected'
            label.style.color = '#888'
        }
    }

    if (data.action === 'freecamToggled') {
        const btn = document.querySelector('button[data-freecam]')
        if (btn) {
            btn.textContent = data.active ? '📷 Freecam: ON' : '📷 Toggle Freecam'
            btn.style.borderColor = data.active ? '#4a6fa5' : ''
            btn.style.color = data.active ? '#a8c8ff' : ''
        }
    }
})

// Close UI with Escape
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        post('closeUI')
    }
})

// ========================
// ACTOR CONTROLS
// ========================
function spawn() {
    const idInput = document.getElementById('charId')
    const id = parseInt(idInput.value)
    if (!id || id < 1) {
        showNotification('Enter a valid character ID.', 'error')
        return
    }
    post('action', { type: 'spawnActor', id: id })
    idInput.value = ''
}

function createCharacter() {
    post('action', { type: 'createCharacter' })
}

function selectNearestActor() {
    post('action', { type: 'selectNearest' })
}

function toggleFreecam() {
    post('action', { type: 'toggleFreecam' })
}

// ========================
// ANIMATIONS
// ========================
let animations = {}

function loadAnimations() {
    post('getAnimations')
        .then(res => res.json())
        .then(data => {
            animations = data
            renderCategories()
        })
}

function renderCategories() {
    const catDiv = document.getElementById('categories')
    catDiv.innerHTML = ''
    Object.keys(animations).forEach(cat => {
        const btn = document.createElement('button')
        btn.classList.add('category-btn')
        btn.textContent = cat
        btn.onclick = () => {
            document.querySelectorAll('.category-btn').forEach(b => b.classList.remove('active'))
            btn.classList.add('active')
            renderAnimations(cat)
        }
        catDiv.appendChild(btn)
    })
}

function renderAnimations(category) {
    const animDiv = document.getElementById('animations')
    animDiv.innerHTML = ''
    animations[category].forEach(anim => {
        const btn = document.createElement('button')
        btn.textContent = anim.label
        btn.onclick = () => playAnim(anim.dict, anim.anim)
        animDiv.appendChild(btn)
    })
}

function playAnim(dict, anim) {
    post('playAnim', { dict, anim })
}

// ========================
// TIMELINE
// ========================
function addStep() {
    const input = document.getElementById('stepDuration')
    const duration = parseInt(input.value) || 3000
    if (duration < 100) {
        showNotification('Duration must be at least 100ms.', 'error')
        return
    }

    post('addStep', { duration })
        .then(res => res.json())
        .then(renderTimeline)
}

function loadTimeline() {
    post('getTimeline')
        .then(res => res.json())
        .then(renderTimeline)
}

function renderTimeline(timeline) {
    const container = document.getElementById('timeline')
    container.innerHTML = ''

    if (!timeline || timeline.length === 0) {
        container.innerHTML = '<div class="empty-msg">No steps yet. Set a duration and add a step.</div>'
        return
    }

    timeline.forEach((step, index) => {
        const div = document.createElement('div')
        div.classList.add('timeline-step')
        div.innerHTML = `
            <div class="step-header">
                <b>Step ${index + 1}</b>
                <span>🎭 ${step.actors.length} actor(s) ${step.camera ? '&nbsp;📷' : ''}</span>
            </div>
            <div class="step-duration-row" id="step-view-${index}">
                <span class="step-ms">${step.duration}ms</span>
                <div class="step-actions">
                    <button onclick="startEditStep(${index})">✏️</button>
                    <button onclick="removeStep(${index})">❌</button>
                </div>
            </div>
            <div class="step-edit-row" id="step-edit-${index}" style="display:none;">
                <input type="number" id="step-input-${index}" value="${step.duration}" min="100" />
                <div class="step-actions">
                    <button onclick="confirmEditStep(${index})">✅</button>
                    <button onclick="cancelEditStep(${index})">✖</button>
                </div>
            </div>
        `
        container.appendChild(div)
    })
}

function startEditStep(index) {
    document.getElementById(`step-view-${index}`).style.display = 'none'
    document.getElementById(`step-edit-${index}`).style.display = 'flex'
    document.getElementById(`step-input-${index}`).focus()
}

function cancelEditStep(index) {
    document.getElementById(`step-view-${index}`).style.display = 'flex'
    document.getElementById(`step-edit-${index}`).style.display = 'none'
}

function confirmEditStep(index) {
    const val = parseInt(document.getElementById(`step-input-${index}`).value)
    if (!val || val < 100) return
    post('updateStep', { index, duration: val })
        .then(res => res.json())
        .then(renderTimeline)
}

function removeStep(index) {
    // Inline confirmation: swap button text
    const btn = event.currentTarget
    if (btn.dataset.confirming) {
        post('removeStep', { index })
            .then(res => res.json())
            .then(renderTimeline)
    } else {
        btn.dataset.confirming = '1'
        btn.textContent = '❓ Sure?'
        btn.style.color = '#f0a0a0'
        setTimeout(() => {
            if (btn.dataset.confirming) {
                delete btn.dataset.confirming
                btn.textContent = '❌'
                btn.style.color = ''
            }
        }, 2500)
    }
}

function play() {
    post('action', { type: 'playTimeline' })
}

// ========================
// SCENE SAVE / LOAD
// ========================
function saveScene() {
    const nameInput = document.getElementById('sceneName')
    const name = nameInput.value.trim()
    if (!name) {
        showNotification('Enter a scene name first.', 'error')
        nameInput.focus()
        return
    }

    post('saveScene', { name })
        .then(res => res.json())
        .then(() => {
            showNotification('Scene "' + name + '" saved!', 'success')
            nameInput.value = ''
            loadScenes()
        })
}

// Import JSON inline
function toggleImport() {
    const area = document.getElementById('importArea')
    area.style.display = area.style.display === 'none' ? 'block' : 'none'
    if (area.style.display === 'block') {
        document.getElementById('importJson').focus()
    }
}

function confirmImport() {
    const raw = document.getElementById('importJson').value.trim()
    if (!raw) return
    post('loadSceneLocal', { scene: raw })
        .then(() => {
            loadTimeline()
            document.getElementById('importJson').value = ''
            document.getElementById('importArea').style.display = 'none'
            showNotification('Scene imported!', 'success')
        })
}

function cancelImport() {
    document.getElementById('importJson').value = ''
    document.getElementById('importArea').style.display = 'none'
}

// ========================
// SCENE LIST (DB)
// ========================
let sceneList = []

function loadScenes() {
    post('getScenes')
}

function renderScenes(filter) {
    filter = (filter || '').toLowerCase()
    const container = document.getElementById('sceneList')
    if (!container) return
    container.innerHTML = ''

    const filtered = sceneList.filter(s => s.name.toLowerCase().includes(filter))

    if (filtered.length === 0) {
        container.innerHTML = '<div class="empty-msg">No saved scenes found.</div>'
        return
    }

    filtered.forEach(scene => {
        const card = document.createElement('div')
        card.classList.add('scene-card')
        card.dataset.id = scene.id
        card.innerHTML = `
            <div class="scene-info">
                <b>${scene.name}</b>
                <small>ID: ${scene.id}</small>
            </div>
            <div class="scene-actions">
                <button onclick="loadSceneById(${scene.id}, this)">▶ Load</button>
                <button onclick="deleteScene(${scene.id}, this)">🗑</button>
            </div>
        `
        container.appendChild(card)
    })
}

function filterScenes() {
    renderScenes(document.getElementById('sceneSearch').value)
}

function loadSceneById(id, btn) {
    if (btn.dataset.confirming) {
        post('loadSceneFromDB', { id })
            .then(() => {
                setTimeout(() => loadTimeline(), 300)
                showNotification('Scene ' + id + ' loaded!', 'success')
                // Reset button
                delete btn.dataset.confirming
                btn.textContent = '▶ Load'
                btn.style.color = ''
            })
    } else {
        btn.dataset.confirming = '1'
        btn.textContent = '❓ Sure?'
        btn.style.color = '#f0a0a0'
        setTimeout(() => {
            if (btn.dataset.confirming) {
                delete btn.dataset.confirming
                btn.textContent = '▶ Load'
                btn.style.color = ''
            }
        }, 2500)
    }
}

function deleteScene(id, btn) {
    if (btn.dataset.confirming) {
        post('deleteScene', { id })
        showNotification('Scene ' + id + ' deleted.', 'error')
    } else {
        btn.dataset.confirming = '1'
        btn.textContent = '❓ Sure?'
        btn.style.color = '#f0a0a0'
        setTimeout(() => {
            if (btn.dataset.confirming) {
                delete btn.dataset.confirming
                btn.textContent = '🗑'
                btn.style.color = ''
            }
        }, 2500)
    }
}

// ========================
// NOTIFICATION TOAST
// ========================
function showNotification(msg, type) {
    let toast = document.getElementById('sd-toast')
    if (!toast) {
        toast = document.createElement('div')
        toast.id = 'sd-toast'
        document.body.appendChild(toast)
    }
    toast.textContent = msg
    toast.className = 'sd-toast ' + (type || '')
    toast.style.opacity = '1'
    clearTimeout(toast._timer)
    toast._timer = setTimeout(() => { toast.style.opacity = '0' }, 2500)
}
