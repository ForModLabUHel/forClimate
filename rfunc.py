import numpy as np
import rpy2


def convert_to_floatmatrix(obj):
    (rows,cols)=np.shape(obj) 
    return rpy2.robjects.r.matrix(obj,nrow=rows,ncol=cols)

def convert_to_floatvector(obj):
    return  rpy2.robjects.vectors.FloatVector(obj)

def convert_r(obj_v,obj_m):
    """
    Convert vector to r compatible vector 
    and matrix to r compatible matrix
    @param obj_v Single line data datframe 
    @param obj_m Matrix or data frame
    @retval (obj_v_r,obj_m_r) R comptible vector and matrix 
    """
    obj_v_r = convert_to_floatvector(obj_v.to_numpy()[0])
    obj_m_r = convert_to_floatmatrix(obj_m.to_numpy())
    return (obj_v_r,obj_m_r)
