window.HiveCloud = (() => {
  async function request(path, options = {}) {
    const response = await fetch(path, {
      ...options,
      headers: {
        ...(options.body instanceof FormData ? {} : { "Content-Type": "application/json" }),
        ...(options.headers || {})
      }
    });

    const contentType = response.headers.get("Content-Type") || "";
    const payload = contentType.includes("application/json") ? await response.json() : null;

    if (!response.ok) {
      throw new Error(payload?.error || `Error HTTP ${response.status}`);
    }

    return payload;
  }

  function isAvailable() {
    return location.protocol === "https:" || location.hostname === "localhost" || location.hostname === "127.0.0.1";
  }

  async function health() {
    return request("/api/health");
  }

  async function fetchRoom(room) {
    return request(`/api/rooms/${encodeURIComponent(room)}`);
  }

  async function saveRecord(id, record) {
    return request(`/api/records/${encodeURIComponent(id)}`, {
      method: "PUT",
      body: JSON.stringify(record)
    });
  }

  async function uploadPhoto(recordId, room, dataUrl) {
    const blob = await (await fetch(dataUrl)).blob();
    const form = new FormData();
    form.set("recordId", recordId);
    form.set("room", room);
    form.set("file", blob, `${recordId.replaceAll("::", "-")}.jpg`);

    return request("/api/uploads", {
      method: "POST",
      body: form
    });
  }

  return {
    isAvailable,
    health,
    fetchRoom,
    saveRecord,
    uploadPhoto
  };
})();
