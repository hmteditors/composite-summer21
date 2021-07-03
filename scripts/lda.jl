using TopicModelsVB
using Random
using Distributions


Random.seed!(10)
corp = readcorp(:nsf) 

corp.docs = corp[1:5000];
fixcorp!(corp, trim=true)
### It's strongly recommended that you trim your corpus when reducing its size in order to remove excess vocabulary. 

### Notice that the post-fix vocabulary is smaller after removing all but the first 5000 docs.

model = LDA(corp, 9)

train!(model, iter=150, tol=0)
### Setting tol=0 will ensure that all 150 iterations are completed.
### If you don't want to compute the ∆elbo, set checkelbo=Inf.

### training...

showtopics(model, cols=9, 20)