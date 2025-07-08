SELECT

*

FROM `academic-observatory.openaire.relation`

WHERE sourceType = 'product' AND targetType = 'product' --- not run
---WHERE sourceType = 'product' AND targetType = 'datasource'
---WHERE sourceType = 'product' AND targetType = 'organization'
---WHERE sourceType = 'product' AND targetType = 'project'
---WHERE sourceType = 'organization' AND targetType = 'project'
---WHERE sourceType = 'organization' AND targetType = 'datasource'
---WHERE sourceType = `organization' AND targetType = 'organization'
