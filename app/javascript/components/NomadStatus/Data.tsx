interface NomadStatusData {
  detail: {
    groups: any[],
  };
  summary: {
    status: string,
    allocations: { [s: string]: number },
  };
}

export default NomadStatusData;
