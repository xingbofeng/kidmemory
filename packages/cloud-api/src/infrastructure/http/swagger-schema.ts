export function schemaRef(name: string) {
  return { $ref: `#/components/schemas/${name}` };
}
