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

function extractDeployedImage(data: NomadStatusData): string|null {
  const firstGroup = data.detail.groups[0];
  if (firstGroup) {
    const firstTask = firstGroup.tasks[0];
    if (firstTask) return firstTask.config.image;
  }
  return null;
}

async function fetchNomadStatus(nomadStatusEndpoint: string): Promise<NomadStatusData> {
  const response = await fetch(nomadStatusEndpoint);
  return await response.json();
}

export default NomadStatusData;
export { fetchNomadStatus, extractDeployedImage };
