import { hot } from 'react-hot-loader';

import _ from 'lodash';
import React from 'react';

import fetch from 'util/fetch';

import NomadStatusData from 'components/NomadStatus/Data';

interface AllocationStatusState {
  loading: boolean;
  error: boolean;
  data?: NomadStatusData;
}

interface AllocationStatusProps {
  endpoint: string;
}

class AllocationStatus extends React.Component<AllocationStatusProps, AllocationStatusState> {
  public state: AllocationStatusState = {
    error: false,
    loading: true,
  };

  public componentDidMount() {
    this.fetchData();
  }

  public render() {
    return (
      <div className='AllocationStatus'>
        { this.state.loading ? this.loadingMessage : this.content }
      </div>
    );
  }

  private get loadingMessage() {
    return <div className='AllocationStatus-loadingMessage alert alert-secondary'>Loading allocation status…</div>;
  }

  private get content() {
    if (this.state.error || !this.state.data) return this.errorMessage;
    if (!this.state.data.summary) return null;

    return <div>{ this.instances }</div>;
  }

  private get instances() {
    if (this.state.error || !this.state.data) return null;

    return (
      <div className='instances'>
        { _.map(this.state.data.summary.allocations, this.instance) }
       </div>
    );
  }

  private instance(count: number, type: string) {
    return (
      <div className='instance' key={ type }>
        <span className={ `swatch ${ type }` }/>
        <small>{ count } { _.capitalize(type) }</small>
      </div>
    );
  }

  private get errorMessage() {
    return <div className='AllocationStatus-errorMessage alert alert-danger'>Error fetching data from Nomad.</div>;
  }

  private async fetchData() {
    try {
      const data = await fetch(this.props.endpoint);
      const json = await data.json();

      this.setState({ data: json, loading: false });
    } catch (_) {
      this.setState({ error: true, loading: false });
    }
  }
}

export default hot(module)(AllocationStatus);
