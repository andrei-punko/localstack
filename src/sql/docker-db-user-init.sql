create user rdsadmin;

--
-- DEV
--

-- drop user andd3dfx_dev_user;
CREATE USER andd3dfx_dev_user PASSWORD 'pass_dev';
ALTER USER andd3dfx_dev_user SET search_path TO andd3dfx_dev_schema;

-- drop user andd3dfx_dev_viewer;
CREATE USER andd3dfx_dev_viewer PASSWORD 'pass_dev_viewer';

--
-- QA
--

-- drop user andd3dfx_qa_user;
CREATE USER andd3dfx_qa_user PASSWORD 'pass_qa';
ALTER USER andd3dfx_qa_user SET search_path TO andd3dfx_qa_schema;

-- drop user andd3dfx_qa_viewer;
CREATE USER andd3dfx_qa_viewer PASSWORD 'pass_qa_viewer';
