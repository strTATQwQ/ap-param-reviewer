export const parseParamFile = (text) => {
  const lines = text.split(/\r?\n/);
  const params = new Map();
  lines.forEach((line, i) => {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) return;
    const [k, v] = trimmed.split(/,|\s+/);
    if (k && v !== undefined) params.set(k, { value: v, line: i });
  });
  return { params, lines };
};

export const applyPatches = (originalLines, patches, approvedIds) => {
  let newLines = [...originalLines];
  const activePatches = patches.filter(p => approvedIds.has(p.id));
  
  activePatches.forEach(patch => {
    const idx = newLines.findIndex(l => l.trim().startsWith(patch.key + ",") || l.trim().startsWith(patch.key + " "));
    if (idx !== -1) {
      const oldLine = newLines[idx];
      newLines[idx] = oldLine.includes(",") ? `${patch.key},${patch.new}` : `${patch.key} ${patch.new}`;
    } else if (patch.op === "add") {
      newLines.push(`${patch.key},${patch.new}`);
    }
  });
  return newLines.join("\n");
};
