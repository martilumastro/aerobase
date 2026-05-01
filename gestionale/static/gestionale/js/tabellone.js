const boardBody = document.getElementById("board-body");
const boardDate = document.getElementById("board-date");
const boardTime = document.getElementById("board-time");

function updateClock() {
    const now = new Date();

    boardDate.textContent = now.toLocaleDateString("it-IT", {
        weekday: "long",
        day: "2-digit",
        month: "long",
        year: "numeric"
    });

    boardTime.textContent = now.toLocaleTimeString("it-IT", {
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit"
    });
}

function renderFlights(flights) {
    if (!flights.length) {
        boardBody.innerHTML = '<div class="flight-board-empty">Nessun volo previsto nelle prossime ore.</div>';
        return;
    }

    boardBody.innerHTML = flights.map((flight) => {
        const delay = flight.ritardo_minuti > 0
            ? `<small>+${flight.ritardo_minuti} min</small>`
            : `<small>--</small>`;

        const mutedClass = flight.stato === "partito" ? "flight-board-muted" : "";

        return `
            <div class="flight-board-grid flight-board-flight ${mutedClass}">
                <span class="flight-board-code">${flight.numero_volo}</span>
                <span>${flight.partenza}</span>
                <span>${flight.destinazione}</span>
                <span>${flight.orario_partenza}</span>
                <span>${flight.orario_stimato} ${delay}</span>
                <span>${flight.gate}</span>
                <span>
                    <b class="status status-${flight.stato}">
                        ${flight.stato_label}
                    </b>
                </span>
            </div>
        `;
    }).join("");
}

async function loadBoard() {
    try {
        const response = await fetch("/api/tabellone/");
        const data = await response.json();
        renderFlights(data.voli);
    } catch (error) {
        boardBody.innerHTML = '<div class="flight-board-empty">Impossibile aggiornare il tabellone.</div>';
    }
}

updateClock();
loadBoard();

setInterval(updateClock, 1000);
setInterval(loadBoard, 10000);
