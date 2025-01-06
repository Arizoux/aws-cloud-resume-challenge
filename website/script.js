const apiEndpoint = "https://f4225epu8e.execute-api.eu-north-1.amazonaws.com/getVisitorCount"
const count = document.getElementById("viewerCount")

async function fetchViewerCount() {

    let response = await fetch(apiEndpoint);
    let data = await response.json();

    count.textContent = data;
}

fetchViewerCount();