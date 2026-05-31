export type StatusTransitions = Record<string, readonly string[]>;

export function isValidStatusTransition(from: string, to: string, transitions: StatusTransitions): boolean {
  return transitions[from]?.includes(to) ?? false;
}
