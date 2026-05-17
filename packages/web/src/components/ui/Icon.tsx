type IconName =
  | 'arrow-left'
  | 'bear-avatar'
  | 'book'
  | 'brush'
  | 'camera'
  | 'check'
  | 'child'
  | 'cloud-upload'
  | 'delete'
  | 'download'
  | 'filter'
  | 'folder'
  | 'grid'
  | 'home'
  | 'image'
  | 'info'
  | 'leaf'
  | 'link'
  | 'more'
  | 'palette'
  | 'pdf'
  | 'search'
  | 'settings'
  | 'shield'
  | 'time'
  | 'upload'

interface IconProps {
  name: IconName
  label?: string
  className?: string
}

export function Icon({ name, label, className = '' }: IconProps) {
  return (
    <img
      className={`ui-icon ${className}`.trim()}
      src={`/icons/${name}.png`}
      alt={label ?? ''}
      aria-hidden={label ? undefined : true}
    />
  )
}
