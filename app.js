const roomRanges = [
  [101, 119],
  [201, 219],
  [301, 319],
  [401, 419],
  [501, 519],
  [601, 619],
  [701, 719],
  [801, 812],
  [901, 910]
];

const rooms = roomRanges.flatMap(([start, end]) =>
  Array.from({ length: end - start + 1 }, (_, index) => String(start + index))
);

const categories = [
  {
    name: "Puerta habitacion",
    items: [
      ["No. de habitacion", "SANTI", "sello negro"],
      ["Marco", "MIFE", "revisar pintura"],
      ["Chapa assa abloy", "ASSA ABLOY", "funcionamiento"],
      ["Tope de puerta", "VITECH", "firmeza"],
      ["Seguro/dead bolt", "MIFE", "firmeza"],
      ["Mirilla", "MIFE", ""],
      ["Guillotina acustica", "MIFE", ""],
      ["Sello perimetral", "MIFE", "instalacion"],
      ["Hoyo en marcos silenciadores", "MIFE", ""],
      ["Cierra puertas automatico", "MIFE", ""],
      ["Zoclo de aluminio", "MIFE", ""]
    ]
  },
  {
    name: "Carpinteria",
    items: [
      ["Escritorio", "BAKAN", "revisar pijas y clavos"],
      ["Maletero", "BAKAN", "revisar pijas, clavos y firmeza"],
      ["Buros", "BAKAN", "revisar pijas, clavos y firmeza"],
      ["Base de cama", "BAKAN", "revisar pijas y clavos"],
      ["Ajuste de closet a plafon", "BAKAN", "revisar ajuste y/o cuna"],
      ["Ajuste de closet a piso", "BAKAN", "revisar ajuste y/o cuna"]
    ]
  },
  {
    name: "Electrico",
    items: [
      ["Acabado de columna circular", "DG", ""],
      ["Registro de lamina pintado", "HERMES", ""],
      ["Termostato", "HERMES", ""],
      ["Rebabeo de durock y pegaporcelanato", "REMEDIOS", ""]
    ]
  },
  {
    name: "Interior bano",
    items: [
      ["Regadera", "QM", ""],
      ["Junteo vertical porcelanato muro", "OBRA", ""],
      ["Pintura en plafon de bano", "DG", ""],
      ["Junteo horizontal porcelanato plafon", "OBRA", ""],
      ["Riel de ajuste en plafon", "VITECH", ""],
      ["Toallero en regadera", "QM", ""],
      ["Luna espejo", "VITECH", ""],
      ["Monomando sellado", "QM", ""],
      ["Sello en chapeton regadera", "QM", ""],
      ["Tope en puerta de cancel corredizo", "VITECH", ""],
      ["Lavamanos", "QM", ""],
      ["Piezas rotas de porcelanato", "REMEDIOS", ""],
      ["Fijacion de wc y sellado", "QM", ""],
      ["Pruebas de hermeticidad WC, coladeras y lavabo", "QM", ""],
      ["Contacto falla a tierra", "HUERTA", ""],
      ["2 Punto de luz en bano", "HUERTA", ""],
      ["Apagadores", "HUERTA", ""]
    ]
  },
  {
    name: "Limpieza",
    items: [
      ["Limpieza de muros de concreto", "SANTI", "aspirado y sellado"],
      ["Limpieza de plafon", "SANTI", "aspirado y sellado"],
      ["Limpieza trabe de acero", "SANTI", "limpieza"],
      ["Limpieza de cancel de bano", "SANTI", "limpieza"],
      ["Limpieza cancel corredizo", "SANTI", "limpieza"]
    ]
  },
  {
    name: "Canceleria",
    items: [
      ["Descuadre de cancel corredizo", "VITECH", ""],
      ["Instalacion de barandal", "VITECH", ""],
      ["Sello en exterior", "VITECH", ""],
      ["Sello en interior", "VITECH", ""],
      ["Sellos aluminio cristal", "VITECH", ""],
      ["Junquillo de goma", "VITECH", "verificar si esta completo"],
      ["Sello en acceso a bano", "SANTI", ""],
      ["Recibir canal de aluminio", "SANTI", ""],
      ["Cortinero de aluminio", "VITECH", ""]
    ]
  },
  {
    name: "Cortinas",
    items: [
      ["Frescura, bastones y deslizamiento", "", ""],
      ["Black out, bastones y deslizamiento", "", ""],
      ["Rieles limpios", "", ""]
    ]
  },
  {
    name: "Equipamiento",
    items: [
      ["Modem GRANDSTREAM", "RICARDO", ""],
      ["Television SMART TV", "GGROUP", ""],
      ["Telefono wifi", "RICARDO", ""],
      ["Minibar", "GGROUP", ""],
      ["Caja fuerte", "GGROUP", ""],
      ["Cafetera", "GGROUP", ""],
      ["Amenidades regadera", "GGROUP", ""],
      ["Amenidades lavamanos", "GGROUP", ""],
      ["Secadora", "GGROUP", ""],
      ["Plancha y burro", "GGROUP", ""],
      ["Toallas", "GGROUP", ""],
      ["Sabanas", "GGROUP", ""],
      ["Almohadas", "GGROUP", ""],
      ["Duvet", "GGROUP", ""],
      ["Pie de cama", "GGROUP", ""],
      ["Cojin deco", "GGROUP", ""],
      ["Bote de basura", "GGROUP", ""],
      ["Ganchos", "GGROUP", ""],
      ["Cuadro decorativo", "GGROUP", ""],
      ["Detector de humo", "GGROUP", ""],
      ["Base de tv / pantalla", "GGROUP", ""],
      ["Silla escritorio", "GGROUP", ""],
      ["Tapete de alfombra", "GGROUP", ""],
      ["Colchones", "GGROUP", ""]
    ]
  }
];

const state = {
  room: rooms[0],
  category: categories[0].name,
  query: "",
  date: new Date().toISOString().slice(0, 10),
  inspector: "",
  records: loadRecords()
};

const elements = {
  roomSelect: document.querySelector("#roomSelect"),
  inspectorInput: document.querySelector("#inspectorInput"),
  dateInput: document.querySelector("#dateInput"),
  categoryTabs: document.querySelector("#categoryTabs"),
  checklist: document.querySelector("#checklist"),
  searchInput: document.querySelector("#searchInput"),
  completedMetric: document.querySelector("#completedMetric"),
  pendingMetric: document.querySelector("#pendingMetric"),
  defectiveMetric: document.querySelector("#defectiveMetric"),
  itemTemplate: document.querySelector("#itemTemplate"),
  reportDialog: document.querySelector("#reportDialog"),
  reportText: document.querySelector("#reportText"),
  reportButton: document.querySelector("#reportButton"),
  copyReportButton: document.querySelector("#copyReportButton"),
  shareReportButton: document.querySelector("#shareReportButton"),
  exportCsvButton: document.querySelector("#exportCsvButton")
};

let cloudReady = false;
let isApplyingCloudUpdate = false;

function keyFor(room, category, item) {
  return `${room}::${category}::${item}`;
}

function loadRecords() {
  try {
    return JSON.parse(localStorage.getItem("hive-avances-records")) || {};
  } catch {
    return {};
  }
}

function saveRecords() {
  localStorage.setItem("hive-avances-records", JSON.stringify(state.records));
}

function getRecord(category, item) {
  const key = keyFor(state.room, category, item);
  if (!state.records[key]) {
    state.records[key] = {
      status: "pendiente",
      note: "",
      photos: [],
      updatedAt: null,
      date: state.date,
      inspector: state.inspector
    };
  }
  return state.records[key];
}

function updateRecord(category, item, patch) {
  const record = getRecord(category, item);
  const key = keyFor(state.room, category, item);
  Object.assign(record, patch, {
    room: state.room,
    category,
    item,
    updatedAt: new Date().toISOString(),
    date: state.date,
    inspector: state.inspector
  });
  saveRecords();
  if (cloudReady && window.HiveCloud && !isApplyingCloudUpdate) {
    window.HiveCloud.saveRecord(key, toRemoteRecord(key, record)).catch((error) => {
      setCloudStatus("Error al guardar en nube", "error");
      console.error(error);
    });
  }
  renderMetrics();
}

function initControls() {
  rooms.forEach((room) => {
    const option = document.createElement("option");
    option.value = room;
    option.textContent = room;
    elements.roomSelect.append(option);
  });

  elements.roomSelect.value = state.room;
  elements.dateInput.value = state.date;

  categories.forEach((category) => {
    const button = document.createElement("button");
    button.type = "button";
    button.textContent = category.name;
    button.addEventListener("click", () => {
      state.category = category.name;
      renderTabs();
      renderChecklist();
    });
    elements.categoryTabs.append(button);
  });

  elements.roomSelect.addEventListener("change", (event) => {
    state.room = event.target.value;
    renderChecklist();
    renderMetrics();
    loadCloudRoom().catch((error) => {
      setCloudStatus("Error al cargar habitacion", "error");
      console.error(error);
    });
  });

  elements.dateInput.addEventListener("change", (event) => {
    state.date = event.target.value;
  });

  elements.inspectorInput.addEventListener("input", (event) => {
    state.inspector = event.target.value.trim();
  });

  elements.searchInput.addEventListener("input", (event) => {
    state.query = event.target.value.trim().toLowerCase();
    renderChecklist();
  });

  elements.reportButton.addEventListener("click", openReport);
  elements.copyReportButton.addEventListener("click", copyReport);
  elements.shareReportButton.addEventListener("click", shareReport);
  elements.exportCsvButton.addEventListener("click", exportCsv);
}

function renderTabs() {
  [...elements.categoryTabs.children].forEach((button) => {
    button.classList.toggle("active", button.textContent === state.category);
  });
}

function renderChecklist() {
  const category = categories.find((entry) => entry.name === state.category);
  elements.checklist.textContent = "";

  category.items
    .filter(([name, owner, hint]) => {
      const haystack = `${name} ${owner} ${hint}`.toLowerCase();
      return haystack.includes(state.query);
    })
    .forEach(([name, owner, hint]) => {
      const record = getRecord(category.name, name);
      Object.assign(record, {
        room: state.room,
        category: category.name,
        item: name,
        owner
      });
      const node = elements.itemTemplate.content.cloneNode(true);
      const card = node.querySelector(".itemCard");
      const title = node.querySelector("h2");
      const subtitle = node.querySelector("p");
      const pill = node.querySelector(".statusPill");
      const note = node.querySelector("textarea");
      const file = node.querySelector("input[type='file']");
      const preview = node.querySelector(".photoPreview");

      title.textContent = name;
      subtitle.textContent = [owner && `Especialidad: ${owner}`, hint].filter(Boolean).join(" | ");
      note.value = record.note || "";
      updateStatusUi(card, pill, record.status);
      renderPhotos(preview, record.photos);

      node.querySelectorAll(".segmented button").forEach((button) => {
        button.classList.toggle("active", button.dataset.status === record.status);
        button.addEventListener("click", () => {
          updateRecord(category.name, name, { status: button.dataset.status });
          updateStatusUi(card, pill, button.dataset.status);
          card.querySelectorAll(".segmented button").forEach((inner) => {
            inner.classList.toggle("active", inner === button);
          });
        });
      });

      note.addEventListener("change", () => {
        updateRecord(category.name, name, { note: note.value.trim() });
      });

      file.addEventListener("change", async () => {
        const image = file.files[0];
        if (!image) return;
        const dataUrl = await fileToDataUrl(image);
        const key = keyFor(state.room, category.name, name);
        let photo = dataUrl;

        if (cloudReady && window.HiveCloud) {
          try {
            await window.HiveCloud.saveRecord(key, toRemoteRecord(key, getRecord(category.name, name)));
            const upload = await window.HiveCloud.uploadPhoto(key, state.room, dataUrl);
            photo = upload.photo;
            setCloudStatus("Nube sincronizada", "online");
          } catch (error) {
            setCloudStatus("Foto pendiente local", "error");
            console.error(error);
          }
        }

        const photos = [...(record.photos || []), photo].slice(-3);
        updateRecord(category.name, name, { photos });
        renderPhotos(preview, photos);
        file.value = "";
      });

      elements.checklist.append(node);
    });
}

function updateStatusUi(card, pill, status) {
  pill.textContent = status;
  pill.className = `statusPill ${status}`;
  card.dataset.status = status;
}

function renderPhotos(container, photos = []) {
  container.textContent = "";
  photos.forEach((photo) => {
    const img = document.createElement("img");
    img.src = typeof photo === "string" ? photo : photo.url;
    img.alt = "Foto de avance";
    container.append(img);
  });
}

function fileToDataUrl(file) {
  return new Promise((resolve, reject) => {
    if (!file.type.startsWith("image/")) {
      reject(new Error("El archivo no es una imagen"));
      return;
    }
    const reader = new FileReader();
    reader.onload = () => {
      const img = new Image();
      img.onload = () => {
        const maxSize = 900;
        const scale = Math.min(1, maxSize / Math.max(img.width, img.height));
        const canvas = document.createElement("canvas");
        canvas.width = Math.round(img.width * scale);
        canvas.height = Math.round(img.height * scale);
        const context = canvas.getContext("2d");
        context.drawImage(img, 0, 0, canvas.width, canvas.height);
        resolve(canvas.toDataURL("image/jpeg", 0.72));
      };
      img.onerror = reject;
      img.src = reader.result;
    };
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
}

function allRoomRecords() {
  return categories.flatMap((category) =>
    category.items.map(([name, owner, hint]) => ({
      category: category.name,
      name,
      owner,
      hint,
      ...getRecord(category.name, name)
    }))
  );
}

function renderMetrics() {
  const records = allRoomRecords();
  const completed = records.filter((record) => record.status === "completado").length;
  const pending = records.filter((record) => record.status === "pendiente").length;
  const defective = records.filter((record) => record.status === "defectuoso").length;
  const percent = Math.round((completed / records.length) * 100);

  elements.completedMetric.textContent = `${percent}%`;
  elements.pendingMetric.textContent = pending;
  elements.defectiveMetric.textContent = defective;
}

function buildReport() {
  const records = allRoomRecords();
  const completed = records.filter((record) => record.status === "completado");
  const pending = records.filter((record) => record.status === "pendiente");
  const defective = records.filter((record) => record.status === "defectuoso");
  const notes = records.filter((record) => record.note);
  const percent = Math.round((completed.length / records.length) * 100);

  const lines = [
    "REPORTE DIARIO - HIVE CENTRO HISTORICO",
    `Fecha: ${state.date}`,
    `Habitacion: ${state.room}`,
    `Responsable: ${state.inspector || "Sin capturar"}`,
    "",
    `Avance: ${percent}%`,
    `Completados: ${completed.length}`,
    `Pendientes: ${pending.length}`,
    `Defectuosos: ${defective.length}`,
    "",
    "Defectuosos / atencion requerida:"
  ];

  defective.forEach((record) => {
    lines.push(`- ${record.category} / ${record.name} (${record.owner || "Sin especialidad"})${record.note ? `: ${record.note}` : ""}`);
  });

  lines.push("", "Observaciones:");
  notes.forEach((record) => {
    lines.push(`- ${record.category} / ${record.name}: ${record.note}`);
  });

  if (!defective.length && !notes.length) {
    lines.push("- Sin observaciones adicionales.");
  }

  return lines.join("\n");
}

function openReport() {
  elements.reportText.value = buildReport();
  elements.reportDialog.showModal();
}

async function copyReport() {
  elements.reportText.select();
  if (navigator.clipboard && window.isSecureContext) {
    await navigator.clipboard.writeText(elements.reportText.value);
    return;
  }
  document.execCommand("copy");
}

async function shareReport() {
  const text = elements.reportText.value || buildReport();
  if (navigator.share) {
    await navigator.share({ title: "Reporte diario Hive", text });
    return;
  }
  location.href = `mailto:?subject=${encodeURIComponent("Reporte diario Hive")}&body=${encodeURIComponent(text)}`;
}

function exportCsv() {
  const header = ["fecha", "habitacion", "categoria", "partida", "especialidad", "estatus", "observacion", "responsable"];
  const rows = allRoomRecords().map((record) => [
    state.date,
    state.room,
    record.category,
    record.name,
    record.owner || "",
    record.status,
    record.note || "",
    state.inspector || record.inspector || ""
  ]);
  const csv = [header, ...rows].map((row) => row.map(csvCell).join(",")).join("\n");
  const blob = new Blob([csv], { type: "text/csv;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = `avance-habitacion-${state.room}-${state.date}.csv`;
  link.click();
  URL.revokeObjectURL(url);
}

function csvCell(value) {
  return `"${String(value).replaceAll('"', '""')}"`;
}

function setCloudStatus(message, className = "") {
  const status = document.querySelector("#cloudStatus");
  if (!status) return;
  status.textContent = message;
  status.className = `cloudStatus ${className}`.trim();
}

function sanitizeRemoteRecord(data) {
  return {
    status: data.status || "pendiente",
    note: data.note || "",
    photos: Array.isArray(data.photos) ? data.photos.slice(0, 3) : [],
    updatedAt: data.updatedAt || null,
    date: data.reportDate || data.date || "",
    inspector: data.inspector || "",
    room: data.room || "",
    category: data.category || "",
    item: data.item || ""
  };
}

function toRemoteRecord(key, record) {
  return {
    id: key,
    room: record.room || state.room,
    category: record.category || key.split("::")[1],
    item: record.item || key.split("::").slice(2).join("::"),
    owner: record.owner || "",
    status: record.status || "pendiente",
    note: record.note || "",
    inspector: state.inspector || record.inspector || "",
    reportDate: state.date || record.date || new Date().toISOString().slice(0, 10)
  };
}

async function loadCloudRoom() {
  if (!cloudReady || !window.HiveCloud) return;

  const response = await window.HiveCloud.fetchRoom(state.room);
  isApplyingCloudUpdate = true;
  response.records.forEach((remoteRecord) => {
    const key = remoteRecord.id;
    state.records[key] = {
      ...sanitizeRemoteRecord(remoteRecord),
      photos: remoteRecord.photos || []
    };
  });
  saveRecords();
  isApplyingCloudUpdate = false;
  renderChecklist();
  renderMetrics();
}

async function initCloudSync() {
  if (!window.HiveCloud || !window.HiveCloud.isAvailable()) {
    setCloudStatus("Modo local");
    return;
  }

  setCloudStatus("Conectando nube...");

  try {
    await window.HiveCloud.health();
    cloudReady = true;
    setCloudStatus("Nube sincronizada", "online");
    await loadCloudRoom();
  } catch (error) {
    cloudReady = false;
    setCloudStatus("Modo local: API no disponible", "error");
  }
}

initControls();
renderTabs();
renderChecklist();
renderMetrics();
initCloudSync();
