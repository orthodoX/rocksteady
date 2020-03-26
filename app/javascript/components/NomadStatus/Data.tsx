import fetch from 'util/fetch';

interface NomadStatusData {
  detail: {
    groups: any[],
  };
  summary: {
    status: string,
    allocations: { [s: string]: number },
  };
}

function extractDeployedImage(data: any): string|null {
  if (!data.detail) return null;
  const firstGroup = (data.detail.groups || [])[0];
  if (firstGroup) {
    const firstTask = firstGroup.tasks[0];
    if (firstTask) return firstTask.config.image;
  }
  return null;
}

async function fetchNomadStatus(nomadStatusEndpoint: string) {
  const response = await fetch(nomadStatusEndpoint);
  return await response.json();
}

export default NomadStatusData;
export { fetchNomadStatus, extractDeployedImage };
