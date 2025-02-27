% buildMesh2d Construct a triangular grid a two-dimensional planar domain.
% The grid is initially built onto the reference square, then mapped to the 
% physical domain, which may have the following shape:
% - quadrilateral
% 
% [mesh,domain] = buildMesh2d(geometry)
% [mesh,domain] = buildMesh2d('quadrilater', 'A',A, 'B',B, 'C',C, 'D',D, 'Hmax',Hmax)
%
% \param geometry   string reporting the shape of the domain:
%                   - 'quad': quadrilateral domain
% \out   mesh_r     mesh2d over the reference domain
% \out   mesh       mesh2d over the physical domain
% \out   domain     struct storing details about the physical domain; these 
%                   can be set through the optional input arguments
%
% Optional arguments for quadrilateral domains:
% \param A          coordinates of the first vertex; default is [0 0]'
% \param B          coordinates of the second vertex; default is [1 0]'
% \param C          coordinates of the third vertex; default is [1 1]'
% \param D          coordinates of the fourth vertex; default is [0 1]'
% \param Hmax       length of the longest edge in the mesh over the
%                   reference domain; default is 0.05

function [mesh_r, mesh, domain] = buildMesh2d(geometry, varargin)
    % Declare persistent variables
    persistent pHmax pmesh_r pnodes pnodes_ext pelems
        
    % Differentiate according to the shape of the domain
    if strcmp(geometry,'quad')        
        % Set default values for options
        A = [0 0]';  B = [1 0]';  C = [1 1]';  D = [0 1]';  Hmax = 0.05;
        
        % Catch user-defined values for options
        for i = 1:2:length(varargin)
            if strcmp(varargin{i},'A')
                if size(varargin{i+1},1) > 1
                    A = varargin{i+1};
                else
                    A = varargin{i+1}';
                end
            elseif strcmp(varargin{i},'B')
                if size(varargin{i+1},1) > 1
                    B = varargin{i+1};
                else
                    B = varargin{i+1}';
                end
            elseif strcmp(varargin{i},'C')
                if size(varargin{i+1},1) > 1
                    C = varargin{i+1};
                else
                    C = varargin{i+1}';
                end
            elseif strcmp(varargin{i},'D')
                if size(varargin{i+1},1) > 1
                    D = varargin{i+1};
                else
                    D = varargin{i+1}';
                end
            elseif strcmp(varargin{i},'Hmax')
                Hmax = varargin{i+1};
            else
                warning('Unknown option ''%s''. Ignored.',varargin{i}{1})
            end
        end
        
        % Check if the mesh on reference domain must be (re-)built
        if (isempty(pHmax) || pHmax ~= Hmax)
            % Set the vertices
            x = [0 1 1 0];  y = [0 0 1 1];
            
            % Create the geometry and set it within a PDE model
            model = createpde;
            gd = [3 4 x y]';  dl = decsg(gd);  geometryFromEdges(model,dl);

            % Build the mesh
            mesh_r = generateMesh(model,'Hmax',Hmax);

            % Convert to a mesh2d object
            mesh_r = mesh2d(mesh_r.Nodes, mesh_r.Elements, ...
                mesh_r.MaxElementSize, mesh_r.MinElementSize);
            
            % Update persistent variables
            pHmax = Hmax;  pmesh_r = mesh_r;  
            pnodes = mesh_r.nodes;  pelems = mesh_r.elems;
            pnodes_ext = [pnodes; pnodes(1,:).*pnodes(2,:); ones(1,pmesh_r.getNumNodes())];
        end
                        
        % Map the grid from reference to phisical domain
        M = [B-A D-A A-B+C-D A];  
        S = repmat(A,1,pmesh_r.getNumNodes());
        mesh = mesh2d(M*pnodes_ext+S,pelems);
        
        % Store domain details in a struct
        domain = struct('A',A, 'B',B, 'C',C, 'D',D);
    else
        error('Unknown input geometry. Available geometries:\n\t''quadrilateral''.')
    end
    
    % Set output
    mesh_r = pmesh_r;
end
        
        
    